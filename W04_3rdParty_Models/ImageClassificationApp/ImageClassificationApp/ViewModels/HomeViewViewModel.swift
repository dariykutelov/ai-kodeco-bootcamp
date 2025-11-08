//
//  HomeViewViewModel.swift
//  ImageClassificationApp
//
//  Created by Dariy Kutelov on 7.11.25.
//

import SwiftUI
import Observation
import PhotosUI

@Observable final class HomeViewViewModel {
    
    // MARK: - Properties
    
    var selectedImage: UIImage?
    var selectedPickerItem: PhotosPickerItem? {
        didSet {
            if let item = selectedPickerItem {
                loadImage(from: item)
            }
        }
    }
    var errorMessage: String? = nil
    var selectedModel: SelectedModel = .yolov8x_cls_converted
    var classificationResult: (label: String, probability: Float)?
    var isClassifying: Bool = false
    private var classificationWorkItem: DispatchWorkItem?
    private var classificationIdentifier = UUID()
    
    
    //MARK: - Photo Picker
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        self.errorMessage = nil
                    } else {
                        self.selectedImage = nil
                        self.errorMessage = "Unable to decode selected image."
                    }
                case .failure(let error):
                    self.selectedImage = nil
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    // MARK: - Classify Image
    
    func classifyImage() {
        classificationWorkItem?.cancel()
        errorMessage = nil
        
        guard let image = selectedImage else {
            classificationWorkItem = nil
            classificationResult = nil
            isClassifying = false
            if selectedPickerItem != nil {
                errorMessage = "No image selected."
            }
            return
        }
        
        let model = selectedModel
        classificationResult = nil
        isClassifying = true
        let identifier = UUID()
        classificationIdentifier = identifier
        
        let workItem = DispatchWorkItem { [weak self, model, image, identifier] in
            guard let self else { return }
            let classifier = ImageClassifier(selectedModel: model)
            let result = classifier.classify(image: image)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                guard self.classificationIdentifier == identifier else { return }
                self.classificationResult = result
                self.isClassifying = false
                self.classificationWorkItem = nil
                
                if result == nil {
                    self.errorMessage = "Unable to classify image."
                } else {
                    self.errorMessage = nil
                }
            }
        }
        
        classificationWorkItem = workItem
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
    }
    
    
    //MARK: - Helper Functions
    
    func reset() {
        self.selectedImage = nil
        self.errorMessage = nil
        self.selectedPickerItem = nil
        self.classificationResult = nil
        self.isClassifying = false
        classificationWorkItem?.cancel()
        classificationWorkItem = nil
        classificationIdentifier = UUID()
    }
}


