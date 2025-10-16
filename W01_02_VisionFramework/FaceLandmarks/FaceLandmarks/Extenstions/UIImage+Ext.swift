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
    func drawGooglyEyes(landmarks: VNFaceLandmarks2D?, boundingBox: CGRect?) -> UIImage? {
      
      print("Original UIImage has an orientation of: \(self.imageOrientation.rawValue)")
      
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
        drawGooglyEye(eye: leftEye, boundingBox: boundingBox, imageSize: imageSize, context: context)
      }
      
      if let rightEye = landmarks.rightEye {
        drawGooglyEye(eye: rightEye, boundingBox: boundingBox, imageSize: imageSize, context: context)
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
      print("Final image needs an orientation of \(correctlyOrientedImage.imageOrientation.rawValue) to look right.")
      return correctlyOrientedImage
    }
    
    private func drawGooglyEye(eye: VNFaceLandmarkRegion2D, boundingBox: CGRect, imageSize: CGSize, context: CGContext) {
      let points = eye.normalizedPoints
      guard !points.isEmpty else { return }
      
      let imagePoints = convertEyePointsToImageCoordinates(points: points, boundingBox: boundingBox)
      let eyeCenter = calculateEyeCenter(from: imagePoints)
      let googlyEyeSize = calculateGooglyEyeSize(from: points, imageSize: imageSize)
      let googlyEyeCenter = CGPoint(
        x: eyeCenter.x * imageSize.width,
        y: eyeCenter.y * imageSize.height
      )
      
      drawWhiteOuterCircle(center: googlyEyeCenter, size: googlyEyeSize)
      drawBlackInnerCircle(center: googlyEyeCenter, size: googlyEyeSize)
    }
    
    private func convertEyePointsToImageCoordinates(points: [CGPoint], boundingBox: CGRect) -> [CGPoint] {
      print("=== Step 1: Coordinate Conversion ===")
      print("Original eye points (face-relative):")
      for (index, point) in points.enumerated() {
        print("  Point \(index): x=\(point.x), y=\(point.y)")
      }
      print("Face bounding box: \(boundingBox)")
      
      let imagePoints = recalculateFromBoundingBoxToImage(normalizedPoints: points, boundingBox: boundingBox)
      
      print("Converted eye points (image-relative):")
      for (index, point) in imagePoints.enumerated() {
        print("  Point \(index): x=\(point.x), y=\(point.y)")
      }
      print("================================")
      
      return imagePoints
    }
    
    private func calculateEyeCenter(from imagePoints: [CGPoint]) -> CGPoint {
      let centerX = imagePoints.map { $0.x }.reduce(0, +) / CGFloat(imagePoints.count)
      let centerY = imagePoints.map { $0.y }.reduce(0, +) / CGFloat(imagePoints.count)
      return CGPoint(x: centerX, y: centerY)
    }
    
    private func calculateGooglyEyeSize(from points: [CGPoint], imageSize: CGSize) -> CGFloat {
      let originalMinX = points.map { $0.x }.min() ?? 0
      let originalMaxX = points.map { $0.x }.max() ?? 0
      let originalMinY = points.map { $0.y }.min() ?? 0
      let originalMaxY = points.map { $0.y }.max() ?? 0
      let originalEyeWidth = originalMaxX - originalMinX
      let originalEyeHeight = originalMaxY - originalMinY
      
      print("=== Size Calculation Debug ===")
      print("Original eye width (normalized): \(originalEyeWidth)")
      print("Original eye height (normalized): \(originalEyeHeight)")
      print("Image size: \(imageSize.width) x \(imageSize.height)")
      
      let eyeWidthPixels = originalEyeWidth * imageSize.width
      let eyeHeightPixels = originalEyeHeight * imageSize.height
      let maxEyeDimension = max(eyeWidthPixels, eyeHeightPixels)
      let adjustmentFactor = 1.0
      let googlyEyeSize = maxEyeDimension * adjustmentFactor
      
      print("Eye width in pixels: \(eyeWidthPixels)")
      print("Eye height in pixels: \(eyeHeightPixels)")
      print("Max dimension: \(maxEyeDimension)")
      print("Googly eye size: \(googlyEyeSize)")
      print("=============================")
      
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
    
    private func drawBlackInnerCircle(center: CGPoint, size: CGFloat) {
      let blackCircleSize = size * 0.4
      let blackCircleRect = CGRect(
        x: center.x - blackCircleSize / 2,
        y: center.y - blackCircleSize / 2,
        width: blackCircleSize,
        height: blackCircleSize
      )
      
      UIColor.black.setFill()
      let blackCirclePath = UIBezierPath(ovalIn: blackCircleRect)
      blackCirclePath.fill()
    }
    
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

//      private func adjustYCoordinateForOrientation(_ normalizedY: CGFloat, imageSize: CGSize, originalImage: UIImage) -> CGFloat {
//        let originalOrientation = originalImage.imageOrientation
//        let adjustedOrientation = adjustOrientation(orient: originalOrientation)
//        
//        print("Y coordinate adjustment: original=\(normalizedY), originalOrientation=\(originalOrientation.rawValue), adjustedOrientation=\(adjustedOrientation.rawValue)")
//        print("No Y coordinate adjustment needed")
//        return normalizedY
//  }
}

