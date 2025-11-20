//
//  ImagePickerView.swift
//  CalorieMeter
//
//  Created by Pavel Klopat on 19.11.25.
//

import SwiftUI
import PhotosUI

// MARK: - Constants
private enum Constants {
    static var photoPickerSelectionLimit: Int { 1 }
}

// MARK: - ImagePickerView
@MainActor
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = Constants.photoPickerSelectionLimit

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView

        // MARK: - Init
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else { return }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    // Safely capture image on main actor
                    if let uiImage = image as? UIImage {
                        Task { @MainActor in
                            withAnimation(.spring) {
                                // Create a copy to avoid data race
                                self.parent.selectedImage = uiImage.fixedOrientation()
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - extension UIImage
// used for track orieentation metadata and rotate if required
extension UIImage {
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}
