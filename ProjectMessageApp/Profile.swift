import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
struct ProfileView: View {
    @State private var firstName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var errorMessage: String? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    private let db = Firestore.firestore()
    @State private var userProfileImageUrl: String? = nil
    @State private var originalUsername = ""
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.init(hex: "#3632a8").ignoresSafeArea(edges: .top)
                    VStack(spacing: 4) {
                        Text("Profile")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Manage personal details")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .frame(height: 80)
                VStack(spacing: 20) {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding()
                    } else {
                        ProfileImageView(imageUrl: userProfileImageUrl)
                            .frame(width: 120, height: 120)
                            .padding()
                    }
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Change Profile Image")
                            .font(.headline)
                            .foregroundColor(Color.init(hex:"#0c55c9"))
                    }
                    .onChange(of: selectedItem) {
                        Task {
                            if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                                let image = UIImage(data: data) {
                                self.image = image
                                uploadImage { url in
                                    if let url = url {
                                        print(" Image uploaded. URL: \(url)")
                                    }
                                }
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("First Name")
                         .font(.headline)
                        
                        TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("Username")
                         .font(.headline)
                        
                        TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        
                        Text("Email")
                         .font(.headline)
                        
                        TextField("Email", text: $email)
                        .disabled(true)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
       
                    }
                    .padding(.horizontal)
                                       
                    Button(action: saveProfile) {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.init(hex: "#3632a8"))
                            .cornerRadius(8)
                    }
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    Spacer()
                }
                .padding()
                .onAppear(perform: loadProfileData)
            }
        }
    }
    private func loadProfileData() {
        guard let currentUserEmail = currentUserEmail else { return }
        db.collection("users").document(currentUserEmail).getDocument { document, error in
            if let error = error {
                print("Error loading user profile: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists,
                  let data = document.data() else {
                return
            }
            let user = User(document: data, id: document.documentID)
            firstName = user.firstName
            username = user.username
            originalUsername = user.username
            email = user.email
            userProfileImageUrl = user.profileImageUrl ?? ""
        }
    }

    
    
    private func saveProfile() {
        guard let email = currentUserEmail else { return }

        if username == originalUsername {
               print("No changes made to username.")
               return
           }
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking username: \(error.localizedDescription)")
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                print("Username is already taken.")
                errorMessage="Username already taken"
                return
            }
            let updatedData: [String: Any] = [
                "firstName": firstName,
                "username": username
            ]
            db.collection("users").document(email).updateData(updatedData) { error in
                if let error = error {
                    print("Failed to update: \(error.localizedDescription)")
                } else {
                    print("Profile updated successfully")
                }
            }
        }
    }
    
    

    private func uploadImage(completion: @escaping (URL?) -> Void) {
        guard let imageData = image?.jpegData(compressionQuality: 0.2) else {
            completion(nil)
            return
        }
        guard let userEmail = currentUserEmail else {
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("profileImages/\(userEmail).jpg")
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

                    db.collection("users").document(userEmail).setData(["profileImageUrl": urlString], merge: true)

                    completion(url)
                } else {
                    completion(nil)
                }
            }
            
        }
    }

}
#Preview {
    ProfileView()
}

