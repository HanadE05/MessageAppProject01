//
//  ImageUploadManager.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 15/04/2025.
//


import FirebaseStorage
import FirebaseFirestore
import UIKit
import FirebaseAuth

struct ImageUploadManager {
    private var userEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }
    static func uploadImage(
        image: UIImage,
        userEmail: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference()
            .child("Images/\(UUID().uuidString).jpg")

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

                    Firestore.firestore().collection("users")
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
