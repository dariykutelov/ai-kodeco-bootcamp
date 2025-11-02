//
//  HomeViewViewModel.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import SwiftUI
import Observation
import PhotosUI

@Observable final class HomeViewViewModel {
    
    // MARK: - Props
    
    private let classifier = DogBreedClassifier()
    var selectedImage: UIImage?
    var selectedPickerItem: PhotosPickerItem? {
        didSet {
            if let item = selectedPickerItem {
                loadImage(from: item)
            }
        }
    }
    var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    var dogBreed: Breeds = .unknown
    var accuracy: Float?
    var errorMessage: String?
    
    // MARK: - Classify Image
    
    func classifyImage() {
        guard let image = self.selectedImage else {
            print("classifyImage() - no image available")
            return
        }
        
        print("classifyImage() - starting classification")
        Task {
            do {
                let (breed, confidence) = try await classifier.classify(image: image)
                print("Classification result - breed: \(breed ?? "nil"), confidence: \(confidence ?? -1)")
                
                await MainActor.run {
                    guard let breedName = breed else {
                        print("classifyImage() - no breed name returned")
                        return
                    }
                    
                    print("classifyImage() - setting breed: \(breedName), accuracy: \((confidence ?? 0) * 100.0)")
                    self.errorMessage = nil
                    self.dogBreed = Breeds(rawValue: breedName) ?? .unknown
                    self.accuracy = (confidence ?? 0) * 100.0
                    print("classifyImage() - dogBreed: \(self.dogBreed), accuracy: \(self.accuracy ?? -1)")
                }
            } catch {
                print("classifyImage() - error: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.dogBreed = .unknown
                    self.accuracy = nil
                }
            }
        }
    }
    
    
    // MARK: - Helpers
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedImage = uiImage
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "Failed to convert data to UIImage"
                    }
                case .failure(let error):
                    self.errorMessage = "Error loading image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func reset() {
        DispatchQueue.main.async {
            self.selectedImage = nil
            self.dogBreed = .unknown
            self.accuracy = nil
            self.errorMessage = nil
        }
    }
}


// MARK: - Camera permissions

extension HomeViewViewModel {
    func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        DispatchQueue.main.async {
            self.cameraPermissionStatus = status
        }
    }
    
    func requestCameraPermissions() {
        print("requestCameraPermissions() - requesting access")
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("requestCameraPermissions() - granted: \(granted)")
            self.checkCameraPermissions()
        }
    }
}
