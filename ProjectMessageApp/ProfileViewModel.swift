//
//  ProfileViewModel.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 17/02/2025.
//
import Foundation
import SwiftUI
import PhotosUI

@MainActor // Ensures all UI updates happen on the main thread
class ProfileViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            Task {
                do {
                    try await loadImage()
                } catch {
                    print("Error loading image: \(error)")
                }
            }
        }
    }

    @Published var profileImage: Image?

    func loadImage() async throws {
        guard let item = selectedItem else { return }
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: imageData) else { return }
        
        // Ensure the UI update happens on the main thread
        self.profileImage = Image(uiImage: uiImage)
    }
}
