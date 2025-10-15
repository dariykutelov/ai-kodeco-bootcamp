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
import Combine

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
    var faceObservations: [VNFaceObservation] = []
    var errorMessage: String? = nil
    
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


//MARK: - Face Detection

extension HomeViewModel {
    @MainActor func detectFaces() {
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
      
      let faceDetectionRequest = VNDetectFaceLandmarksRequest { [weak self] request, error in
          if let error = error {
              DispatchQueue.main.async {
                  self?.errorMessage = "Face detection error: \(error.localizedDescription)"
              }
              return
          }
        
          let observations: [VNFaceObservation] = request.results?.compactMap {
              $0 as? VNFaceObservation
          } ?? []
        
          DispatchQueue.main.async {
              self?.faceObservations = observations
              self?.errorMessage = observations.isEmpty ? "No faces detected" : nil
          }
      }
      
  #if targetEnvironment(simulator)
        let supportedDevices = try! faceDetectionRequest.supportedComputeStageDevices
        if let mainStage = supportedDevices[.main] {
            if let cpuDevice = mainStage.first(where: { device in
                device.description.contains("CPU")
            }) {
                faceDetectionRequest.setComputeDevice(cpuDevice, for: .main)
            }
        }
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

// MARK: - Draw Image

extension HomeViewModel {
    func drawFaceLandmarks() -> UIImage? {
      
        guard let image = selectedOrCapturedImage, let cgImage = image.cgImage else {
            return nil
        }
      
        guard let faceObservation = faceObservations.first else { return image }
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        let faceRect = VNImageRectForNormalizedRect(faceObservation.boundingBox, Int(imageSize.width), Int(imageSize.height))
    
        if let landmarks = faceObservation.landmarks {
            UIColor.green.setStroke()
            UIColor.green.setFill()

            let drawLandmarkRegion = { (region: VNFaceLandmarkRegion2D) in
                let points = region.normalizedPoints
                let landmarkPath = UIBezierPath()
                for (index, point) in points.enumerated() {
                    let normalizedPoint = CGPoint(
                        x: faceObservation.boundingBox.origin.x + point.x * faceObservation.boundingBox.width,
                        y: faceObservation.boundingBox.origin.y + point.y * faceObservation.boundingBox.height
                    )
                    let imagePoint = VNImagePointForNormalizedPoint(normalizedPoint, Int(imageSize.width), Int(imageSize.height))

                    if index == 0 {
                        landmarkPath.move(to: imagePoint)
                    } else {
                        landmarkPath.addLine(to: imagePoint)
                    }
                }
          
              landmarkPath.lineWidth = 1.5
              landmarkPath.stroke()
            }

            if let leftEye = landmarks.leftEye {
              drawLandmarkRegion(leftEye)
            }
            if let rightEye = landmarks.rightEye {
              drawLandmarkRegion(rightEye)
            }
            
            if let nose = landmarks.nose {
              drawLandmarkRegion(nose)
            }
            
            if let noseCrest = landmarks.noseCrest {
              drawLandmarkRegion(noseCrest)
            }
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        print("original orientation is \(image.imageOrientation.rawValue)")
        UIGraphicsEndImageContext()
        let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!, scale: image.scale, orientation: adjustOrientation(orient: image.imageOrientation))

        print("final orientation \(correctlyOrientedImage.imageOrientation.rawValue)")

        return correctlyOrientedImage
    }
    
    func adjustOrientation(orient: UIImage.Orientation) -> UIImage.Orientation {
        switch orient {
            case .up: return .downMirrored
            case .upMirrored: return .up

            case .down: return .upMirrored
            case .downMirrored: return .down

            case .left: return .rightMirrored
            case .rightMirrored: return .left

            case .right: return .leftMirrored //check
            case .leftMirrored: return .right

            @unknown default: return orient
        }
    }
}
