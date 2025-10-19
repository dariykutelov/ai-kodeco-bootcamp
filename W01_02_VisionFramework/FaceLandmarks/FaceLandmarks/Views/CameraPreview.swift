//
//  CameraPreview.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 15.10.25.
//

import UIKit
import AVFoundation
import Vision

/// UIView that displays the live camera feed and draws googly eyes on detected faces
class CameraPreview: UIView {
    var session: AVCaptureSession? {
        get { previewLayer.session }
        set { previewLayer.session = newValue }
    }

    private var eyeLayers: [CALayer] = []
    private var smileEMA: CGFloat = 0
    private var smileEMAInitialized: Bool = false
    private var lastSmileState: Bool = false
    private var lastSmileToggleTime: CFTimeInterval = 0

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func drawGooglyEyes(on faces: [VNFaceObservation]) {
        eyeLayers.forEach { $0.removeFromSuperlayer() }
        eyeLayers.removeAll()

        for face in faces {
            guard let landmarks = face.landmarks else { continue }

            if let leftEye = landmarks.leftEye,
               let rightEye = landmarks.rightEye {
                displayEye(leftEye, in: face, isLeft: true)
                displayEye(rightEye, in: face, isLeft: false)
            }
        }
    }

    private func displayEye(_ eye: VNFaceLandmarkRegion2D, in face: VNFaceObservation, isLeft: Bool) {
        let boundingBox = face.boundingBox
        
        let eyePoints = eye.normalizedPoints.map { point -> CGPoint in
            let x = boundingBox.origin.x + point.x * boundingBox.size.width
            let y = boundingBox.origin.y + point.y * boundingBox.size.height
            return CGPoint(x: x, y: y)
        }

        guard !eyePoints.isEmpty else { return }
        
        let avgX = eyePoints.map(\.x).reduce(0, +) / CGFloat(eyePoints.count)
        let avgY = eyePoints.map(\.y).reduce(0, +) / CGFloat(eyePoints.count)
        
        let capturePoint = CGPoint(x: avgX, y: avgY)
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: capturePoint)
        let imageName = isLeft ? "leftEye" : "rightEye"
        
        guard let image = UIImage(named: imageName)?.cgImage else { return }

        let isMirrored = previewLayer.connection?.isVideoMirrored ?? false
        var minScreenX = CGFloat.greatestFiniteMagnitude
        var maxScreenX = CGFloat.leastNormalMagnitude
        
        for p in eyePoints {
            let cap = CGPoint(x: p.x, y: p.y)
            let conv = previewLayer.layerPointConverted(fromCaptureDevicePoint: cap)
            let sx = isMirrored ? (bounds.width - conv.x) : conv.x
            minScreenX = min(minScreenX, sx)
            maxScreenX = max(maxScreenX, sx)
        }
        
        let eyeWidthOnScreen = max(0, maxScreenX - minScreenX)
        let adjustment: CGFloat = 1.5
        let targetWidth = max(eyeWidthOnScreen * adjustment, 8)
        let aspect = CGFloat(image.height) / CGFloat(image.width)
        let targetHeight = targetWidth * aspect
        let eyeLayer = CALayer()
        eyeLayer.contents = image
        eyeLayer.bounds = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        let finalCenterX = isMirrored ? (bounds.width - converted.x) : converted.x
        let finalPosition = CGPoint(x: finalCenterX, y: bounds.height - converted.y)
        eyeLayer.position = finalPosition
        layer.addSublayer(eyeLayer)
        eyeLayers.append(eyeLayer)
    }
}
