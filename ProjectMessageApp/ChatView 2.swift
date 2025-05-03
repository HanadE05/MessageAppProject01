/*import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct ChatMessagesView2: View {
    let otherUserEmail: String
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var errorMessage: String? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var users: [ChatUser] = []
    @State private var otherUserProfileImageUrl: String? = nil // Profile image of the other user
    @State private var otherUserName: String = "" // Name of the other user




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
                            HStack {
                                if message.senderEmail == currentUserEmail {
                                    Spacer()
                                    
                                    Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    if let imageUrl = message.imageUrl,
                                       let imageData = Data(base64Encoded: imageUrl),
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    else{
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                } else {
                                    if let imageUrl = message.imageUrl,
                                       let imageData = Data(base64Encoded: imageUrl),
                                       let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    else{
                                        Text(message.text)
                                            .padding(10)
                                            .background(Color.purple.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                        
                                        Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
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
                    
                    Button(action: sendMessage) {
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
                                   //Text(otherUserEmail)
                                       //.font(.subheadline)
                                       //.foregroundColor(.gray)
                               }
                           }
                           .frame(maxWidth: .infinity, alignment: .leading) // Align the entire HStack to the left
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

    private func sendMessage() {
        guard !messageText.isEmpty || selectedImage != nil else { return }

        // 🔹 Encrypt the message text before sending
        let encryptedText = encryptionManager.encrypt(plainText: messageText)

        var newMessage: [String: Any] = [
            "text": encryptedText,
            "senderEmail": currentUserEmail,
            "receiverEmail": otherUserEmail,
            "timestamp": Timestamp()
        ]

        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.2) {
            newMessage["imageUrl"] = imageData.base64EncodedString()
        }

        db.collection("messages").document(conversationId).collection("chat").addDocument(data: newMessage) { error in
            if let error = error {
                errorMessage = "Error sending message: \(error.localizedDescription)"
            } else {
                messageText = ""
                selectedImage = nil
            }
        }
    }
    
    
    
    private func uploadImage(completion: @escaping (URL?) -> Void) {
        guard let imageData = image?.jpegData(compressionQuality: 0.2) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference()
            .child("chatImages/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { _, error in
            guard error == nil else {
                print("Upload failed: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let url = url {
                    let urlString = url.absoluteString
                    print("Download url: \(urlString)")

                    db.collection("users")
.document(userEmail)
                        .setData(["profileImageUrl": urlString], merge: true)

                    completion(url)
                } else {
                    completion(nil)
                }
            }
            
        }
    }
    
    
    
    
    
    
}
/*#Preview {
    ChatMessagesView(
        otherUserEmail: "test@example.com"
    )
}




*/






/*
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import PhotosUI

struct ChatMessagesView: View {
    let otherUserEmail: String
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    @State private var errorMessage: String? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?

    private let db = Firestore.firestore()
    private let currentUserEmail = Auth.auth().currentUser?.email ?? ""

    private var conversationId: String {
        [currentUserEmail, otherUserEmail].sorted().joined(separator: "_")
    }

    var body: some View {
        
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { message in
                        HStack {
                            if message.senderEmail == currentUserEmail {
                                Spacer()
                                MessageBubble(message: message, isCurrentUser: true)
                            } else {
                                MessageBubble(message: message, isCurrentUser: false)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }

            HStack {
                Button(action: { isImagePickerPresented = true }) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundColor(Color.init(hex: "#1332bd"))
                }
                TextField("Enter message", text: $messageText)
                    .padding(10)
                    .background(Color.init(hex: "#5e78eb"))
                    .cornerRadius(8)
                    .frame(height: 40)

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                

                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(Color.init(hex: "#1332bd"))
                        .font(.system(size: 24))
                }
            }
            .padding()
            
        }
        .onAppear(perform: loadMessages)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .navigationTitle("Chat with \(otherUserEmail)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadMessages() {
        db.collection("messages").document(conversationId).collection("chat").order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = "Error loading messages: \(error.localizedDescription)"
                    return
                }

                messages = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard
                        let senderEmail = data["senderEmail"] as? String,
                        let receiverEmail = data["receiverEmail"] as? String,
                        let text = data["text"] as? String,
                        let timestamp = data["timestamp"] as? Timestamp
                    else {
                        return nil
                    }
                    return Message(
                        id: document.documentID,
                        text: text,
                        senderEmail: senderEmail,
                        receiverEmail: receiverEmail,
                        imageUrl: data["imageUrl"] as? String,
                        timestamp: timestamp
                    )
                } ?? []
            }
    }

    private func sendMessage() {
        guard !messageText.isEmpty || selectedImage != nil else { return }

        var newMessage: [String: Any] = [
            "text": messageText,
            "senderEmail": currentUserEmail,
            "receiverEmail": otherUserEmail,
            "timestamp": Timestamp()
        ]

        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.2) {
            newMessage["imageUrl"] = imageData.base64EncodedString()
        }

        db.collection("messages")
            .document(conversationId)
            .collection("chat")
            .addDocument(data: newMessage) { error in
                if let error = error {
                    errorMessage = "Error sending message: \(error.localizedDescription)"
                } else {
                    messageText = ""
                    selectedImage = nil
                }
            }
    }
}

struct Message: Identifiable {
    var id: String
    var text: String
    var senderEmail: String
    var receiverEmail: String
    var imageUrl: String?
    var timestamp: Timestamp
}

// Message Bubble View
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading) {
            if let imageUrl = message.imageUrl,
               let imageData = Data(base64Encoded: imageUrl),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            if !message.text.isEmpty {
                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.purple.opacity(0.8))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 50)
    }
}

#Preview {
    ChatMessagesView(
        otherUserEmail: "test@example.com"
    )
}

 */*/
