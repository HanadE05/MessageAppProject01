import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage


struct ChatMessagesView: View {
    let otherUserEmail: String
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var errorMessage: String? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var otherUserProfileImageUrl: String? = nil 
    @State private var otherUserName: String = ""
    private let db = Firestore.firestore()
    @AppStorage("chatBackgroundColor") private var chatBackgroundColor: String = "default"
    private let currentUserEmail = Auth.auth().currentUser?.email ?? ""
    let encryptionManager = EncryptionManager()
    private var conversationId: String {
        [currentUserEmail, otherUserEmail].sorted().joined(separator: "_")
    }
    var body: some View {
        ZStack {
            Image(chatBackgroundColor)
                .resizable()
                .clipped()
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            ChatMessageRow(message: message, isCurrentUser: message.senderEmail == currentUserEmail)
                                .contextMenu {
                                    if message.senderEmail == currentUserEmail {
                                        Button(role: .destructive) {
                                            deleteMessage(messageId: message.id)
                                        } label: {
                                            Label("Delete Message", systemImage: "trash")
                                        }
                                    }
                                }
                        }                    }
                    .padding(.bottom, 30)
                }
                HStack {
                    Button(action: { isImagePickerPresented = true }) {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(Color.init(hex: "#1332bd"))
                    }
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    TextField("Enter message...", text: $messageText)
                        .padding(10)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(8)
                        .frame(height: 40)
                    
                    Button(action: {
                        if let selectedImage = selectedImage {
                            sendImageMessage(image: selectedImage)
                        }
                        else if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            sendTextMessage(text: messageText)
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(Color.init(hex: "#1332bd"))
                            .font(.system(size: 24))
                    }
                }
                .padding()
            }
            .onAppear{
                loadMessages()
                fetchOtherUserDetails()
            }
            .navigationTitle("Chat with \(otherUserEmail)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        ProfileImageView(imageUrl: otherUserProfileImageUrl)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(otherUserName)
                                .font(.headline)
                                .bold()
                                .foregroundStyle(Color.blue)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    private func fetchOtherUserDetails() {
        db.collection("users").whereField("email", isEqualTo: otherUserEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }
            if let document = snapshot?.documents.first {
                let data = document.data()
                otherUserProfileImageUrl = data["profileImageUrl"] as? String
                otherUserName = data["username"] as? String ?? "Unknown"
            }
        }
    }
    private func loadMessages() {
        db.collection("messages").document(conversationId).collection("chat").order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                errorMessage = "Error loading messages: \(error.localizedDescription)"
                return
            }
            messages = snapshot?.documents.compactMap { document in
                var messageData = document.data()
                if let encryptedText = messageData["text"] as? String {
                    messageData["text"] = encryptionManager.decrypt(encryptedText: encryptedText) ?? "Decryption Error"
                }
                return Message(document: messageData, id: document.documentID)
            } ?? []
        }
    }

    func sendTextMessage(text: String) {
        
        let encryptedText = encryptionManager.encrypt(plainText: messageText)
        let messageData: [String: Any] = [
            "text": encryptedText,
            "senderEmail": currentUserEmail,
            "receiverEmail": otherUserEmail,
            "timestamp": Timestamp()
        ]

        db.collection("messages").document(conversationId).collection("chat").addDocument(data: messageData) { error in
                if let error = error {
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    //print("Message sent successfully.")
                    messageText = "" // clear text after sending
                }
            }
    }

    func sendImageMessage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            //print("Failed to get JPEG data.")
            return
        }

        let imageID = UUID().uuidString
        let storageRef = Storage.storage().reference().child("chat_images/\(imageID).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" 

        print("📤 Uploading image to: chat_images/\(imageID).jpg")

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                //print("Error uploading image: \(error.localizedDescription)")
                return
            }

            //print("Image uploaded.")

            storageRef.downloadURL { url, error in
                if let error = error {
                    //print("Error getting download URL: \(error.localizedDescription)")
                    return
                }

                guard let downloadURL = url else {
                    //print("Download URL is nil.")
                    return
                }

                //print("Download URL received: \(downloadURL.absoluteString)")

                let messageData: [String: Any] = [
                    "imageUrl": downloadURL.absoluteString,
                    "senderEmail": currentUserEmail,
                    "receiverEmail": otherUserEmail,
                    "timestamp": Timestamp()
                ]

                db.collection("messages").document(conversationId).collection("chat").addDocument(data: messageData) { error in
                    if let error = error {
                        //print("Error sending image message: \(error.localizedDescription)")
                    } else {
                        //print("Image message sent successfully.")
                        selectedImage = nil
                    }
                }
            }
        }
    }
    func deleteMessage(messageId: String) {
       db.collection("messages").document(conversationId).collection("chat").document(messageId).delete { error in
              if let error = error {
                  print("Error deleting message: \(error.localizedDescription)")
              } else {
                  print("Message deleted")
              }
          }
    }
}
#Preview {
    ChatMessagesView(
        otherUserEmail: "test@example.com"
    )
}



