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
                let smiling = isSmilingOpenCVStyle(landmarks, in: face)
                displayEye(leftEye, in: face, isLeft: true, smiling: smiling)
                displayEye(rightEye, in: face, isLeft: false, smiling: smiling)
            }
        }
    }

    private func displayEye(_ eye: VNFaceLandmarkRegion2D, in face: VNFaceObservation, isLeft: Bool, smiling: Bool) {
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
        let adjustment: CGFloat = smiling ? 1.6 : 1.2
        print("smiling: \(smiling), adjustment: \(adjustment)")
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

    private func isSmilingOpenCVStyle(_ landmarks: VNFaceLandmarks2D, in face: VNFaceObservation) -> Bool {
        guard let outer = landmarks.outerLips else { return false }
        // Convert outer lips to capture normalized and then to preview-layer coordinates (same metric for X/Y)
        let bb = face.boundingBox
        let capPts = outer.normalizedPoints.map { p -> CGPoint in
            CGPoint(x: bb.origin.x + p.x * bb.size.width,
                    y: bb.origin.y + p.y * bb.size.height)
        }
        let layerPts = capPts.map { pt in
            previewLayer.layerPointConverted(fromCaptureDevicePoint: pt)
        }
        guard let leftCorner = layerPts.min(by: { $0.x < $1.x }),
              let rightCorner = layerPts.max(by: { $0.x < $1.x }) else { return false }
        let mouthWidth = abs(rightCorner.x - leftCorner.x)
       
        var mouthHeight: CGFloat = 0
        if let top = layerPts.min(by: { $0.y < $1.y }), // top is smaller y in layer coords
           let bottom = layerPts.max(by: { $0.y < $1.y }) {
            mouthHeight = max(0, bottom.y - top.y)
        }

        let epsilon: CGFloat = 1e-3
        let ratio = mouthWidth / max(mouthHeight, epsilon)

        if !smileEMAInitialized {
            smileEMA = ratio
            smileEMAInitialized = true
        }
        let alpha: CGFloat = 0.35
        smileEMA = (1 - alpha) * smileEMA + alpha * ratio

        let onThreshold: CGFloat = 3.3
        let offThreshold: CGFloat = 3.0
        let now = CACurrentMediaTime()
        let minToggleInterval: CFTimeInterval = 0.4

        var smiling = lastSmileState
        if lastSmileState {
            // Turn OFF only when smoothed value drops below offThreshold (prevents flicker)
            if smileEMA < offThreshold && now - lastSmileToggleTime > minToggleInterval {
                smiling = false
                lastSmileToggleTime = now
                print("smile: OFF ema=\(smileEMA), ratio=\(ratio)")
            }
        } else {
            // Turn ON quickly based on raw ratio crossing onThreshold
            if ratio > onThreshold && now - lastSmileToggleTime > minToggleInterval {
                smiling = true
                lastSmileToggleTime = now
                print("smile: ON ema=\(smileEMA), ratio=\(ratio)")
            }
        }
        lastSmileState = smiling
        return smiling
    }
}
