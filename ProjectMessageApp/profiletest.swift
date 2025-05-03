import FirebaseAuth
import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct ProfileTest: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }
    
    private let db = Firestore.firestore()
    
    @State private var profileImage: UIImage? // Store the profile image as UIImage
    @State private var isUploading = false
    @State private var avatarPhotoItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
          Text("Hello, world!")
            .navigationTitle("Title")
            .navigationBarTitleDisplayMode(.inline)
            Color.blue.ignoresSafeArea(edges: .top)
        }  .frame(height: 80)

        VStack {
            // Display profile image
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                defaultProfileIcon()
            }

            // Show upload progress indicator
            if isUploading {
                ProgressView("Uploading...").padding()
            }

            // Photo picker for selecting an image
            PhotosPicker("Select Image", selection: $avatarPhotoItem, matching: .images)

            // Show error message if image loading fails
            if let loadError = errorMessage {
                Text(loadError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .onAppear {
            fetchProfileImage()
        }
        .task(id: avatarPhotoItem) {
            do {
                if let item = avatarPhotoItem {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        uploadImage(image: uiImage) // ✅ Auto-upload after selection
                    } else {
                        throw URLError(.badServerResponse)
                    }
                }
            } catch {
                errorMessage = "❌ Failed to load image: \(error.localizedDescription)"
                print("Error loading image: \(error)")
            }
        }
    }

    /// Default placeholder profile image
    private func defaultProfileIcon() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 150, height: 150)
            .foregroundColor(.gray)
    }

    /// Fetches the current user's profile image from Firestore
    private func fetchProfileImage() {
        guard let currentUserEmail else { return }
        
        db.collection("users").document(currentUserEmail).getDocument { document, error in
            if let document = document, document.exists,
               let data = document.data(),
               let urlString = data["profileImageUrl"] as? String,
               let url = URL(string: urlString) {
                
                // Download image from URL
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data, let uiImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileImage = uiImage
                        }
                    }
                }.resume()
            }
        }
    }

    /// Uploads selected image to Firebase Storage using `putData`
    private func uploadImage(image: UIImage) {
        isUploading = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.1) else {
            print("Failed to convert image to data")
            isUploading = false
            return
        }
        
        let storageRef = Storage.storage().reference()
            .child("profileImages/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            DispatchQueue.main.async {
                self.isUploading = false
            }
            
            guard error == nil else {
                print("Upload failed: \(error!.localizedDescription)")
                return
            }
            
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get image URL: \(error.localizedDescription)")
                } else if let url = url {
                    self.profileImage = image // Set image immediately after upload
                    saveImageURLToFirestore(url: url)
                }
            }
        }
    }

    /// Saves uploaded image URL to Firestore
    private func saveImageURLToFirestore(url: URL) {
        guard let currentUserEmail else { return }
        db.collection("users").document(currentUserEmail).setData(["profileImageUrl": url.absoluteString], merge: true)
    }
}

#Preview {
    ProfileTest()
}

