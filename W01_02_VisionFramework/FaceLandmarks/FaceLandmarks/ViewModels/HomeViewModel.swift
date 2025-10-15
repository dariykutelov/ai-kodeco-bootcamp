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

@Observable
class HomeViewModel {
    
    // MARK: - Properties
    
    var selectedOrCapturedImage: UIImage?
    
    var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
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
}
