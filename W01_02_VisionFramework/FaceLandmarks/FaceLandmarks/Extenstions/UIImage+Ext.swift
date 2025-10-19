//
//  UIImage+Ext.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 16.10.25.
//

import UIKit
import Vision
import OSLog

extension UIImage {
    
    // MARK: - Google Eyes
    
    func drawGooglyEyes(landmarks: VNFaceLandmarks2D?, boundingBox: CGRect?) -> UIImage? {
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let landmarks = landmarks, let boundingBox = boundingBox else {
            return self
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        
        if let leftEye = landmarks.leftEye {
            drawGooglyEye(eye: leftEye, boundingBox: boundingBox, imageSize: imageSize, context: context, isLeftEye: true)
        }
        
        if let rightEye = landmarks.rightEye {
            drawGooglyEye(eye: rightEye, boundingBox: boundingBox, imageSize: imageSize, context: context, isLeftEye: false)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalCgImage = newImage?.cgImage else {
            return nil
        }
        
        let correctlyOrientedImage = UIImage(
            cgImage: finalCgImage,
            scale: self.scale,
            orientation: self.adjustOrientation()
        )
        return correctlyOrientedImage
    }
    
    private func drawGooglyEye(eye: VNFaceLandmarkRegion2D, boundingBox: CGRect, imageSize: CGSize, context: CGContext, isLeftEye: Bool) {
        let points = eye.normalizedPoints
        guard !points.isEmpty else { return }
        
        let imagePoints = convertEyePointsToImageCoordinates(points: points, boundingBox: boundingBox)
        let eyeCenter = calculateEyeCenter(from: imagePoints)
        let googlyEyeSize = calculateGooglyEyeSize(from: points, boundingBox: boundingBox, imageSize: imageSize)
        let googlyEyeCenter = CGPoint(
            x: eyeCenter.x * imageSize.width,
            y: eyeCenter.y * imageSize.height
        )
        
        drawWhiteOuterCircle(center: googlyEyeCenter, size: googlyEyeSize)
        drawBlackInnerCircle(center: googlyEyeCenter, size: googlyEyeSize, isLeftEye: isLeftEye, imageOrientation: self.imageOrientation)
    }
    
    private func convertEyePointsToImageCoordinates(points: [CGPoint], boundingBox: CGRect) -> [CGPoint] {
        let imagePoints = recalculateFromBoundingBoxToImage(normalizedPoints: points, boundingBox: boundingBox)
        return imagePoints
    }
    
    private func calculateEyeCenter(from imagePoints: [CGPoint]) -> CGPoint {
      let minX = imagePoints.min(by: { $0.x < $1.x })?.x ?? 0
      let maxX = imagePoints.max(by: { $0.x < $1.x })?.x ?? 0
      let minY = imagePoints.min(by: { $0.y < $1.y })?.y ?? 0
      let maxY = imagePoints.max(by: { $0.y < $1.y })?.y ?? 0
        
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2
        return CGPoint(x: centerX, y: centerY)
    }
    
    private func calculateGooglyEyeSize(from points: [CGPoint], boundingBox: CGRect, imageSize: CGSize) -> CGFloat {
        let originalMinX = points.map { $0.x }.min() ?? 0
        let originalMaxX = points.map { $0.x }.max() ?? 0
        let originalMinY = points.map { $0.y }.min() ?? 0
        let originalMaxY = points.map { $0.y }.max() ?? 0
        let originalEyeWidth = originalMaxX - originalMinX
        let originalEyeHeight = originalMaxY - originalMinY
        
        let boundingBoxWidthPixels = boundingBox.width * imageSize.width
        let boundingBoxHeightPixels = boundingBox.height * imageSize.height
        
        let eyeWidthPixels = originalEyeWidth * boundingBoxWidthPixels
        let eyeHeightPixels = originalEyeHeight * boundingBoxHeightPixels
        let maxEyeDimension = max(eyeWidthPixels, eyeHeightPixels)
        let adjustmentFactor = 1.25
        let googlyEyeSize = maxEyeDimension * adjustmentFactor
        
        return googlyEyeSize
    }
    
    private func drawWhiteOuterCircle(center: CGPoint, size: CGFloat) {
        let whiteCircleRect = CGRect(
            x: center.x - size / 2,
            y: center.y - size / 2,
            width: size,
            height: size
        )
        
        UIColor.white.setFill()
        let whiteCirclePath = UIBezierPath(ovalIn: whiteCircleRect)
        whiteCirclePath.fill()
        
        UIColor.black.setStroke()
        whiteCirclePath.lineWidth = 2.0
        whiteCirclePath.stroke()
    }
    
    private func drawBlackInnerCircle(center: CGPoint, size: CGFloat, isLeftEye: Bool, imageOrientation: UIImage.Orientation) {
        let baseBlackCircleSize = size * 0.5
        let blackCircleSize = isLeftEye ? baseBlackCircleSize * 1.2 : baseBlackCircleSize
        
        let offsetPercentage: CGFloat = 0.2
        let offset = (size / 2) * offsetPercentage
        
        let pupilCenter: CGPoint
        switch imageOrientation {
        case .up, .upMirrored:
            let pupilCenterX = isLeftEye ? center.x + offset : center.x - offset
            pupilCenter = CGPoint(x: pupilCenterX, y: center.y)
        case .down, .downMirrored:
            let pupilCenterX = isLeftEye ? center.x - offset : center.x + offset
            pupilCenter = CGPoint(x: pupilCenterX, y: center.y)
        case .left, .leftMirrored:
            let pupilCenterY = isLeftEye ? center.y - offset : center.y + offset
            pupilCenter = CGPoint(x: center.x, y: pupilCenterY)
        case .right, .rightMirrored:
            let pupilCenterY = isLeftEye ? center.y + offset : center.y - offset
            pupilCenter = CGPoint(x: center.x, y: pupilCenterY)
        @unknown default:
            let pupilCenterX = isLeftEye ? center.x + offset : center.x - offset
            pupilCenter = CGPoint(x: pupilCenterX, y: center.y)
        }
        
        let blackCircleRect = CGRect(
            x: pupilCenter.x - blackCircleSize / 2,
            y: pupilCenter.y - blackCircleSize / 2,
            width: blackCircleSize,
            height: blackCircleSize
        )
        
        UIColor.black.setFill()
        let blackCirclePath = UIBezierPath(ovalIn: blackCircleRect)
        blackCirclePath.fill()
    }
    
    // MARK: - Sunglasses Overlay

    func addSunglassesOverlay(landmarks: VNFaceLandmarks2D?,
                              boundingBox: CGRect?,
                              sunglassesImage: UIImage?) -> UIImage? {
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let landmarks = landmarks, let boundingBox = boundingBox, let sunglassesImage = sunglassesImage else {
            return self
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            drawSunglassesOverlay(leftEye: leftEye,
                                  rightEye: rightEye,
                                  landmarks: landmarks,
                                  boundingBox: boundingBox,
                                  imageSize: imageSize,
                                  context: context,
                                  sunglassesImage: sunglassesImage)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalCgImage = newImage?.cgImage else {
            return nil
        }
        
        let correctlyOrientedImage = UIImage(
            cgImage: finalCgImage,
            scale: self.scale,
            orientation: self.adjustOrientation()
        )
        return correctlyOrientedImage
    }
    
    private func drawSunglassesOverlay(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize, context: CGContext, sunglassesImage: UIImage) {
        
        print("=== Sunglasses Vertical Positioning Debug ===")
        print("Sunglasses image size: \(sunglassesImage.size)")
        print("Image size: \(imageSize)")
        
        let leftEyeCenter = calculateEyeCenter(from: convertEyePointsToImageCoordinates(points: leftEye.normalizedPoints, boundingBox: boundingBox))
        let rightEyeCenter = calculateEyeCenter(from: convertEyePointsToImageCoordinates(points: rightEye.normalizedPoints, boundingBox: boundingBox))
        
        let leftEyeCenterPixels = CGPoint(
            x: leftEyeCenter.x * imageSize.width,
            y: leftEyeCenter.y * imageSize.height
        )
        let rightEyeCenterPixels = CGPoint(
            x: rightEyeCenter.x * imageSize.width,
            y: rightEyeCenter.y * imageSize.height
        )
        
        let eyesCenterX = (leftEyeCenterPixels.x + rightEyeCenterPixels.x) / 2
        let eyesCenterY = (leftEyeCenterPixels.y + rightEyeCenterPixels.y) / 2
        
        print("Left eye center (pixels): (\(leftEyeCenterPixels.x), \(leftEyeCenterPixels.y))")
        print("Right eye center (pixels): (\(rightEyeCenterPixels.x), \(rightEyeCenterPixels.y))")
        print("Eyes center Y: \(eyesCenterY)")
        
        // Use simple eye-based positioning (most reliable)
        let sunglassesY = eyesCenterY// Position 25 pixels above eyes
        print("Sunglasses Y: \(sunglassesY)")
        print("Using simple eye-based positioning")
        
        print("Eyes center Y: \(eyesCenterY)")
        print("Final sunglasses Y: \(sunglassesY)")
        
        let distanceBetweenEyes = sqrt(pow(rightEyeCenterPixels.x - leftEyeCenterPixels.x, 2) + pow(rightEyeCenterPixels.y - leftEyeCenterPixels.y, 2))
        let faceWidth = distanceBetweenEyes * 2.5
        
        let widthScaleFactor = faceWidth / sunglassesImage.size.width
        
        let scaledSunglassesWidth = sunglassesImage.size.width * widthScaleFactor
        let scaledSunglassesHeight = (scaledSunglassesWidth * sunglassesImage.size.height) / sunglassesImage.size.width
        
        print("Width scale factor: \(widthScaleFactor)")
        print("Scaled sunglasses size: (\(scaledSunglassesWidth), \(scaledSunglassesHeight))")
        
        let sunglassesRect = CGRect(
            x: eyesCenterX - scaledSunglassesWidth / 2,
            y: sunglassesY - scaledSunglassesHeight / 2,
            width: scaledSunglassesWidth,
            height: scaledSunglassesHeight
        )
        
        print("Final sunglasses rectangle: \(sunglassesRect)")
        print("=========================================")
        
        context.saveGState()
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Adjust Y position for flipped coordinate system
        let flippedRect = CGRect(
            x: sunglassesRect.origin.x,
            y: -sunglassesRect.origin.y - sunglassesRect.height,
            width: sunglassesRect.width,
            height: sunglassesRect.height
        )
        
        sunglassesImage.draw(in: flippedRect)
        context.restoreGState()
    }
    
    // MARK: - Helper Methods
    
    private func recalculateFromBoundingBoxToImage(normalizedPoints: [CGPoint], boundingBox: CGRect) -> [CGPoint] {
        return normalizedPoints.map { point in
            let imageX = boundingBox.origin.x + (point.x * boundingBox.width)
            let imageY = boundingBox.origin.y + (point.y * boundingBox.height)
            return CGPoint(x: imageX, y: imageY)
        }
    }
    
    private func adjustOrientation() -> UIImage.Orientation {
        switch self.imageOrientation {
        case .up:
            return .downMirrored
        case .upMirrored:
            return .up
        case .down:
            return .upMirrored
        case .downMirrored:
            return .down
        case .left:
            return .rightMirrored
        case .rightMirrored:
            return .left
        case .right:
            return .leftMirrored
        case .leftMirrored:
            return .right
        @unknown default:
            return self.imageOrientation
        }
    }
}

