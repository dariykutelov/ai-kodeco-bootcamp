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
                              sunglassesImage: UIImage?,
                              verticalTopToNoseOffset: CGFloat) -> UIImage? {
      
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
                                  sunglassesImage: sunglassesImage,
                                  verticalTopToNoseOffset: verticalTopToNoseOffset)
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
  
    private func drawSunglassesOverlay(leftEye: VNFaceLandmarkRegion2D, rightEye: VNFaceLandmarkRegion2D, landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize, context: CGContext, sunglassesImage: UIImage, verticalTopToNoseOffset: CGFloat) {
        let eye = computeEyeCentersAndAngle(landmarks: landmarks, boundingBox: boundingBox, imageSize: imageSize)
        let isOrientationRight = (self.imageOrientation == .right)
        let leftEyePx = isOrientationRight ? CGPoint(x: imageSize.width - eye.left.y, y: eye.left.x) : eye.left
        let rightEyePx = isOrientationRight ? CGPoint(x: imageSize.width - eye.right.y, y: eye.right.x) : eye.right
        let eyesCenterX = (leftEyePx.x + rightEyePx.x) / 2
        let sunglassesY = (leftEyePx.y + rightEyePx.y) / 2
        let rotationAngle = atan2(rightEyePx.y - leftEyePx.y, rightEyePx.x - leftEyePx.x)
        

        var chosenLeftTop: CGPoint? = nil
        var chosenRightTop: CGPoint? = nil
        var baseWidth: CGFloat? = nil
        if let result = computeContourTopPoints(landmarks: landmarks, boundingBox: boundingBox, imageSize: imageSize) {
            chosenLeftTop = result.leftTop
            chosenRightTop = result.rightTop
            baseWidth = result.width
            
        } else if let w = computeContourWidth(landmarks: landmarks, boundingBox: boundingBox, imageSize: imageSize, eyesCenter: CGPoint(x: eyesCenterX, y: sunglassesY), angle: rotationAngle) {
            baseWidth = w
        }
        guard let contourWidth = baseWidth else { return }
        let scaledSunglassesWidth = contourWidth
        let scaledSunglassesHeight = (scaledSunglassesWidth * sunglassesImage.size.height) / sunglassesImage.size.width
        
        let rectY = sunglassesY - scaledSunglassesHeight / 2
        let rectXCenter: CGFloat = eyesCenterX

        if let lt = chosenLeftTop, let rt = chosenRightTop {
            let r: CGFloat = 20
            let ltRect = CGRect(x: lt.x - r/2, y: lt.y - r/2, width: r, height: r)
            let rtRect = CGRect(x: rt.x - r/2, y: rt.y - r/2, width: r, height: r)
            UIColor.green.setFill()
            UIBezierPath(ovalIn: ltRect).fill()
            UIColor.red.setFill()
            UIBezierPath(ovalIn: rtRect).fill()
        }

        let sunglassesRect = CGRect(x: rectXCenter - scaledSunglassesWidth / 2, y: rectY, width: scaledSunglassesWidth, height: scaledSunglassesHeight)
        context.saveGState()
        context.scaleBy(x: 1.0, y: -1.0)
        let anchorFromTop = (verticalTopToNoseOffset / 100.0) * scaledSunglassesHeight
        let anchorFromBottom = (scaledSunglassesHeight - anchorFromTop) * 1.05
        let flippedRect = CGRect(x: sunglassesRect.origin.x, y: -sunglassesRect.origin.y - sunglassesRect.height, width: sunglassesRect.width, height: sunglassesRect.height)
        let rotationAnchor = CGPoint(x: flippedRect.midX, y: flippedRect.origin.y + anchorFromBottom)
        
        context.translateBy(x: rotationAnchor.x, y: rotationAnchor.y)
        var appliedAngle = -rotationAngle
        if self.imageOrientation == .right {
            appliedAngle += .pi / 2
        }
        context.rotate(by: appliedAngle)
        context.translateBy(x: -rotationAnchor.x, y: -rotationAnchor.y)
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
  
  private func computeEyeCentersAndAngle(landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize) -> (left: CGPoint, right: CGPoint, centerX: CGFloat, centerY: CGFloat, angle: CGFloat) {
    let leftPts = landmarks.leftEye?.normalizedPoints ?? []
    let rightPts = landmarks.rightEye?.normalizedPoints ?? []
    let leftCenterNorm = calculateEyeCenter(from: recalculateFromBoundingBoxToImage(normalizedPoints: leftPts, boundingBox: boundingBox))
    let rightCenterNorm = calculateEyeCenter(from: recalculateFromBoundingBoxToImage(normalizedPoints: rightPts, boundingBox: boundingBox))
    let leftPx = CGPoint(x: leftCenterNorm.x * imageSize.width, y: leftCenterNorm.y * imageSize.height)
    let rightPx = CGPoint(x: rightCenterNorm.x * imageSize.width, y: rightCenterNorm.y * imageSize.height)
    let centerX = (leftPx.x + rightPx.x) / 2
    let centerY = (leftPx.y + rightPx.y) / 2
    let angle = atan2(rightPx.y - leftPx.y, rightPx.x - leftPx.x)
    return (leftPx, rightPx, centerX, centerY, angle)
  }
  
  private func computeContourWidth(landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize, eyesCenter: CGPoint, angle: CGFloat) -> CGFloat? {
    guard let contour = landmarks.faceContour else { return nil }
    let pts = recalculateFromBoundingBoxToImage(normalizedPoints: contour.normalizedPoints, boundingBox: boundingBox)
    let px = pts.map { CGPoint(x: $0.x * imageSize.width, y: $0.y * imageSize.height) }
    guard !px.isEmpty else { return nil }
    print("contour pts=\(px.count) eyesCenter=(\(eyesCenter.x),\(eyesCenter.y)) angleDeg=\(angle * 180.0 / .pi)")
    if let minYPoint = px.min(by: { $0.y < $1.y }) {
      let splitX = minYPoint.x
      let left = px.filter { $0.x <= splitX }
      let right = px.filter { $0.x >= splitX }
      let leftTop = left.max(by: { $0.y < $1.y })
      let rightTop = right.max(by: { $0.y < $1.y })
      print("splitX=\(splitX) leftCount=\(left.count) rightCount=\(right.count) leftTop=\(String(describing: leftTop)) rightTop=\(String(describing: rightTop))")
      if let lt = leftTop, let rt = rightTop {
        let w = abs(rt.x - lt.x)
        print("contour width by tops: lt=(\(lt.x),\(lt.y)) rt=(\(rt.x),\(rt.y)) width=\(w)")
        return w
      }
    }
    let xs = px.map { $0.x }
    guard let minX = xs.min(), let maxX = xs.max() else { return nil }
    print("fallback contour width span=\(maxX - minX)")
    return maxX - minX
  }

  private func computeContourTopPoints(landmarks: VNFaceLandmarks2D, boundingBox: CGRect, imageSize: CGSize) -> (leftTop: CGPoint, rightTop: CGPoint, width: CGFloat)? {
    guard let contour = landmarks.faceContour else { return nil }
    let pts = recalculateFromBoundingBoxToImage(normalizedPoints: contour.normalizedPoints, boundingBox: boundingBox)
    let px = pts.map { CGPoint(x: $0.x * imageSize.width, y: $0.y * imageSize.height) }
    guard !px.isEmpty else { return nil }
    let needsAxisSwap = (self.imageOrientation == .right || self.imageOrientation == .rightMirrored || self.imageOrientation == .left || self.imageOrientation == .leftMirrored)
    if !needsAxisSwap {
      guard let minYPoint = px.min(by: { $0.y < $1.y }) else { return nil }
      let splitX = minYPoint.x
      let left = px.filter { $0.x <= splitX }
      let right = px.filter { $0.x >= splitX }
      guard let leftTop = left.max(by: { $0.y < $1.y }), let rightTop = right.max(by: { $0.y < $1.y }) else { return nil }
      let width = abs(rightTop.x - leftTop.x)
      return (leftTop, rightTop, width)
    } else {
      let rotated: [(orig: CGPoint, rx: CGFloat, ry: CGFloat)] = px.map { p in
        let rx = p.y
        let ry = -p.x
        return (p, rx, ry)
      }
      guard let minRY = rotated.min(by: { $0.ry < $1.ry }) else { return nil }
      let splitRX = minRY.rx
      let left = rotated.filter { $0.rx <= splitRX }
      let right = rotated.filter { $0.rx >= splitRX }
      guard let leftTop = left.max(by: { $0.ry < $1.ry }), let rightTop = right.max(by: { $0.ry < $1.ry }) else { return nil }
      let width = hypot(rightTop.rx - leftTop.rx, rightTop.ry - leftTop.ry)
      return (leftTop.orig, rightTop.orig, width)
    }
  }
  
  private func computeNoseTopAndRectY(landmarks: VNFaceLandmarks2D,
                                      boundingBox: CGRect,
                                      imageSize: CGSize,
                                      scaledHeight: CGFloat,
                                      verticalTopToNoseOffset: CGFloat) -> (top: CGPoint?, rectY: CGFloat?) {
    if let noseRegion = landmarks.noseCrest ?? landmarks.nose {
      let pts = recalculateFromBoundingBoxToImage(normalizedPoints: noseRegion.normalizedPoints, boundingBox: boundingBox)
      let px = pts.map { CGPoint(x: $0.x * imageSize.width, y: $0.y * imageSize.height) }
      if let top = px.max(by: { $0.y < $1.y }) {
        let anchor = (scaledHeight - (verticalTopToNoseOffset / 100.0 * scaledHeight)) * 1.05
        let rectY = (top.y - anchor) * 1.05
        return (top, rectY)
      }
    }
    return (nil, nil)
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

