//
//  HomeViewModel.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import SwiftUI
import Observation
import AVFoundation
import PhotosUI
import Vision

@Observable
class ImageViewModel {
    
    // MARK: - Properties
    
    var selectedOrCapturedImage: UIImage? {
        didSet {
            if selectedOrCapturedImage != nil {
                reset()
            }
        }
    }
    
    var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    var faceObservations: [VNFaceObservation] = []
    var faceBoundingBox: CGRect? = nil
    var faceLandmarks: VNFaceLandmarks2D? = nil
    var errorMessage: String? = nil
    
    var selectedPickerItem: PhotosPickerItem? {
        didSet {
            if let item = selectedPickerItem {
                loadImage(from: item)
            }
        }
    }
    
    // MARK: - init
    
    init() {
        checkCameraPermissions()
    }
    
    //MARK: - Camera Permissions
    
    func checkCameraPermissions() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        DispatchQueue.main.async {
            self.cameraPermissionStatus = status
        }
    }
    
    func requestCameraPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            self.checkCameraPermissions()
        }
    }
    
    //MARK: - Photo Picker
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.selectedOrCapturedImage = uiImage
                    } else {
                        print("Failed to convert data to UIImage")
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    //MARK: - Helper Functions
    func reset() {
        faceObservations = []
        faceBoundingBox = nil
        faceLandmarks = nil
        errorMessage = nil
    }
}


//MARK: - Face Detection

extension ImageViewModel {
    @MainActor func detectFace() {
        self.reset()
        
        guard let image = selectedOrCapturedImage else {
            DispatchQueue.main.async {
                self.errorMessage = "No image available"
            }
            return
        }
        
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to convert UIImage to CGImage"
            }
            return
        }
        
        let faceDetectionRequest = VNDetectFaceLandmarksRequest {  [weak self] request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Face detection error: \(error.localizedDescription)"
                }
                return
            }
            
            let observations: [VNFaceObservation] = request.results?.compactMap {
                $0 as? VNFaceObservation
            } ?? []
            
            let landmarks = observations.first?.landmarks
            let boundingBox = observations.first?.boundingBox
            
            DispatchQueue.main.async {
                self?.faceLandmarks = landmarks
                self?.faceBoundingBox = boundingBox
                self?.errorMessage = observations.isEmpty ? "No faces detected" : nil
            }
        }
        
#if targetEnvironment(simulator)
        faceDetectionRequest.usesCPUOnly = true
#endif
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([faceDetectionRequest])
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to perform detection: \(error.localizedDescription)"
            }
        }
    }
}
