import SwiftUI
import UIKit

// ImagePicker: A SwiftUI wrapper for UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    // A binding to pass the selected image back to the parent SwiftUI view
    @Binding var selectedImage: UIImage?
    
    // Environment variable to dismiss the picker after the user selects an image or cancels
    @Environment(\.presentationMode) private var presentationMode

    // Creates and configures the UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() // Instantiate the image picker
        picker.delegate = context.coordinator // Assign the coordinator as the delegate
        picker.sourceType = .photoLibrary // Set the source to the photo library
        picker.allowsEditing = false // Disable image editing (set to true if editing is required)
        return picker
    }

    // Updates the view controller with new SwiftUI state (not used here)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // This method is left empty because there is no need to update the picker dynamically
    }

    // Creates a coordinator to handle delegate methods from UIImagePickerController
    func makeCoordinator() -> Coordinator {
        Coordinator(self) // Pass the ImagePicker instance to the coordinator
    }

    // Coordinator: Acts as the delegate for UIImagePickerController
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker // Reference to the parent ImagePicker struct

        // Initialize the coordinator with a reference to the parent ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when the user picks an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            // Retrieve the selected image from the picker
            parent.selectedImage = info[.originalImage] as? UIImage
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }

        // Called when the user cancels the picker
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Dismiss the picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
