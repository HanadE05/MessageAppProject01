import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth


struct ImageTest: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    @State private var selectedImage: UIImage?
    @State private var userProfileImageUrl: String? = nil
    @State private var isUploading = false

    private let db = Firestore.firestore()
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }

    var body: some View {
        VStack {
            Spacer()

            ProfileImageView(imageUrl: userProfileImageUrl)
                .frame(width: 120, height: 120)
                .padding()

            Spacer()

            PhotosPicker("Select Image", selection: $selectedItem, matching: .images)

            if isUploading {
                ProgressView("Uploading...").padding()
            } else {
                Button("Upload to Firebase") {
                    if let image = selectedImage, let email = currentUserEmail {
                        isUploading = true
                        ImageUploadManager.uploadImage(image: image, userEmail: email) { url in
                            isUploading = false
                            if let url = url {
                                self.userProfileImageUrl = url.absoluteString
                                print("✅ Image uploaded and saved.")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .task(id: selectedItem) {
            if let item = selectedItem {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    selectedImage = UIImage(data: data)
                }
            }
        }
        .onAppear {
            if let email = currentUserEmail {
                db.collection("users").document(email).getDocument { snapshot, _ in
                    if let data = snapshot?.data(),
                       let imageUrl = data["profileImageUrl"] as? String {
                        userProfileImageUrl = imageUrl
                    }
                }
            }
        }
    }
}
#Preview {
    ImageTest()
}
