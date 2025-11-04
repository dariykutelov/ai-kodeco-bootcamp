import UIKit

extension UIImage {
    func resizeTo360x360() -> UIImage {
        let targetSize = CGSize(width: 360, height: 360)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resizedImage = renderer.image { context in
            context.cgContext.interpolationQuality = .high
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        guard let cgImage = resizedImage.cgImage else {
            return resizedImage
        }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
}

