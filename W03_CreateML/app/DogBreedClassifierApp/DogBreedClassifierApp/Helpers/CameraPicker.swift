//
//  \View.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
}

class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var parent: CameraPicker
    
    init(parent: CameraPicker) {
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("CameraPicker - imagePickerController didFinishPickingMediaWithInfo")
        picker.dismiss(animated: true, completion: nil)
        
        if let uiImage = info[.originalImage] as? UIImage {
            print("CameraPicker - got image, size: \(uiImage.size)")
            DispatchQueue.main.async {
                print("CameraPicker - setting selectedImage on main thread")
                self.parent.selectedImage = uiImage
                print("CameraPicker - selectedImage set")
            }
        } else {
            print("CameraPicker - no image in info dictionary")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("CameraPicker - user cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
}
