//
//  UIImage+Ext.swift
//  FaceLandmarks
//
//  Created by Dariy Kutelov on 16.10.25.
//

import UIKit
import Vision
import OSLog

enum CameraOrientationMode {
    case orientation0
    case orientation3
    case other
}

extension UIImage {
    
    // MARK: - Draw Google Eyes
    
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
                              sunglassesImage: UIImage?,
                              verticalTopToNoseOffset: CGFloat) -> UIImage? {
        
        guard let cgImage = self.cgImage else { return nil }
        guard let landmarks = landmarks, let boundingBox = boundingBox,
              let sunglassesImage = sunglassesImage else { return self }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
        
        drawSunglassesOverlay(
            landmarks: landmarks,
            boundingBox: boundingBox,
            imageSize: imageSize,
            context: context,
            sunglassesImage: sunglassesImage,
            verticalTopToNoseOffset: verticalTopToNoseOffset)
        
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
    
    private func cameraOrientationMode() -> CameraOrientationMode {
        switch self.imageOrientation {
        case .up, .upMirrored:
            return .orientation0
        case .right, .rightMirrored:
            return .orientation3
        default:
            return .other
        }
    }
    
    private func drawSunglassesOverlay(landmarks: VNFaceLandmarks2D,
                                       boundingBox: CGRect,
                                       imageSize: CGSize,
                                       context: CGContext,
                                       sunglassesImage: UIImage,
                                       verticalTopToNoseOffset: CGFloat) {
        
        guard let sunglassesImageWidth = sunglassesImage.cgImage?.width,
              let sunglassesImageHeight  = sunglassesImage.cgImage?.height else { return }
        
        let contourWidth = calculateSunglassesWidth(landmarks: landmarks,
                                                    boundingBox: boundingBox,
                                                    imageSize: imageSize,
                                                    fallbackWidth: sunglassesImageWidth)
        
        let scaledHeight = CGFloat(contourWidth * sunglassesImageHeight / sunglassesImageWidth)
        
        let noseTopPoint = computeNoseTopPoint(landmarks: landmarks,
                                               boundingBox: boundingBox,
                                               imageSize: imageSize)
        
        let sunglassesRect: CGRect
        if let noseTop = noseTopPoint {
            let mode = cameraOrientationMode()
            let rectX: CGFloat
            let rectY: CGFloat
            
            let anchor = (scaledHeight - (verticalTopToNoseOffset / 100.0 * scaledHeight)) * 0.95
            print("anchor: \(anchor)")
            
            switch mode {
            case .orientation3:
                rectX = noseTop.y - CGFloat(contourWidth) / 2 - anchor / 2
                rectY = imageSize.height - noseTop.x - anchor * 2
            default:
                rectX = noseTop.x - CGFloat(contourWidth) / 2
                rectY = noseTop.y - anchor
            }
            
            sunglassesRect = CGRect(x: rectX,
                                    y: rectY,
                                    width: CGFloat(contourWidth),
                                    height: scaledHeight)
        } else {
            sunglassesRect = CGRect(x: 0,
                                    y: 0,
                                    width: CGFloat(contourWidth),
                                    height: scaledHeight)
        }
        
        context.saveGState()
        
        let mode = cameraOrientationMode()
        switch mode {
        case .orientation0:
            let anchor = CGPoint(x: sunglassesRect.midX, y: sunglassesRect.midY)
            context.translateBy(x: anchor.x, y: anchor.y)
            context.scaleBy(x: 1, y: -1)
            context.translateBy(x: -anchor.x, y: -anchor.y)
            break
        case .orientation3:
            let anchor = CGPoint(x: sunglassesRect.midX + sunglassesRect.width/2,
                                 y: sunglassesRect.midY + sunglassesRect.height/2)
            context.translateBy(x: anchor.x, y: anchor.y)
            context.rotate(by: -.pi / 2)
            context.translateBy(x: -anchor.x, y: -anchor.y)
            break
        case .other:
            break
        }
        sunglassesImage.draw(in: sunglassesRect)
        context.restoreGState()
    }
    
    
    // MARK: - Helper Methods
    
    private func convertEyePointsToImageCoordinates(points: [CGPoint], boundingBox: CGRect) -> [CGPoint] {
        return points.map { point in
            let imageX = boundingBox.origin.x + (point.x * boundingBox.width)
            let imageY = boundingBox.origin.y + (point.y * boundingBox.height)
            return CGPoint(x: imageX, y: imageY)
        }
    }
    
    private func mapNormalizedPointToUprightPixels(_ p: CGPoint, boundingBox: CGRect, imageSize: CGSize) -> CGPoint {
        let ax = boundingBox.origin.x + p.x * boundingBox.width
        let ay = boundingBox.origin.y + p.y * boundingBox.height
        let nx: CGFloat
        let ny: CGFloat
        switch self.imageOrientation {
        case .right, .rightMirrored:
            nx = 1 - ay
            ny = ax
        case .left, .leftMirrored:
            nx = ay
            ny = 1 - ax
        case .down, .downMirrored:
            nx = 1 - ax
            ny = 1 - ay
        default:
            nx = ax
            ny = ay
        }
        return CGPoint(x: nx * imageSize.width, y: ny * imageSize.height)
    }
    
    private func computeNoseTopPoint(landmarks: VNFaceLandmarks2D,
                                     boundingBox: CGRect,
                                     imageSize: CGSize) -> CGPoint? {
        if let noseRegion = landmarks.noseCrest ?? landmarks.nose {
            let px = noseRegion.normalizedPoints.map { mapNormalizedPointToUprightPixels($0, boundingBox: boundingBox, imageSize: imageSize) }
            let mode = cameraOrientationMode()
            switch mode {
            case .orientation0:
                return px.max(by: { $0.y < $1.y })
            case .orientation3:
                return px.min(by: { $0.x < $1.x })
            case .other:
                return px.max(by: { $0.y < $1.y })
            }
        }
        return nil
    }
    
    private func calculateSunglassesWidth(landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize, fallbackWidth: Int) -> Int {
        let mode = cameraOrientationMode()
        
        guard let contour = landmarks.faceContour else { return fallbackWidth }
        
        let contourPoints = contour.normalizedPoints.map { point in
            let imageX = boundingBox.origin.x + (point.x * boundingBox.width)
            let imageY = boundingBox.origin.y + (point.y * boundingBox.height)
            return CGPoint(x: imageX * imageSize.width, y: imageY * imageSize.height)
        }
        
        switch mode {
        case .orientation0:
            if let minYPoint = contourPoints.min(by: { $0.y < $1.y }) {
                let splitX = minYPoint.x
                let leftHalf = contourPoints.filter { $0.x <= splitX }
                let rightHalf = contourPoints.filter { $0.x >= splitX }
                let leftTop = leftHalf.max(by: { $0.y < $1.y })
                let rightTop = rightHalf.max(by: { $0.y < $1.y })
                if let lt = leftTop, let rt = rightTop {
                    return Int(abs(rt.x - lt.x))
                }
            }
            return fallbackWidth
            
        case .orientation3:
            if let leftmost = contourPoints.min(by: { $0.x < $1.x }),
               let rightmost = contourPoints.max(by: { $0.x < $1.x }) {
                return Int(abs(rightmost.x - leftmost.x))
            }
            return fallbackWidth
            
        case .other:
            return fallbackWidth
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

