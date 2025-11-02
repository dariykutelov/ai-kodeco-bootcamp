//
//  ClassificationResultViewViewModel.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import Foundation
import FoundationModels
import Observation
import UIKit
import Cloudinary

@Observable final class ClassificationResultViewViewModel {
    let breed: String
    var breedDetails: Breed?
    var errorMessage: String?
    var isUploading = false
    
    private var cloudinary: CLDCloudinary {
        let config = CLDConfiguration(cloudName: cloudinaryCloudName, apiKey: cloudinaryApiKey, apiSecret: cloudinaryApiSecret)
        return CLDCloudinary(configuration: config)
    }
    
    init(breed: String) {
        self.breed = breed

        Task {
            await fetchBreedDetails()
        }
    }
    
    func confirmUpload(image: UIImage?, folder: String) {
        guard let image = image else {
            print("No image to upload")
            return
        }
        
        Task {
            await uploadToCloudinary(image: image, folder: folder)
        }
    }
    
    private func fetchBreedDetails() async {
        guard let breedName =  Breeds(rawValue: breed)?.apiBreedName,
                let url = URL(string: "https://api.api-ninjas.com/v1/dogs?name=\(breedName)") else {
            print("Invalid url")
            return
        }
        
        print(url.absoluteString)
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let breeds = try JSONDecoder().decode([Breed].self, from: data)
            self.breedDetails = breeds.first
            print(self.breedDetails ?? "No breed found")
        } catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func resizeImageTo360x360(_ image: UIImage) -> UIImage {
        let targetSize = CGSize(width: 360, height: 360)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let resizedImage = renderer.image { context in
            context.cgContext.interpolationQuality = .high
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        guard let cgImage = resizedImage.cgImage else {
            return resizedImage
        }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
    }
    
    private func uploadToCloudinary(image: UIImage, folder: String) async {
        await MainActor.run {
            isUploading = true
        }
        
        defer {
            Task { @MainActor in
                isUploading = false
            }
        }
        
        let resizedImage = resizeImageTo360x360(image)
        if let cgImage = resizedImage.cgImage {
            print("Resized image - Points: \(resizedImage.size), Pixels: \(cgImage.width)x\(cgImage.height), Scale: \(resizedImage.scale)")
        }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }
        
        return await withCheckedContinuation { continuation in
            let params = CLDUploadRequestParams()
            params.setFolder(folder)
            
            
            cloudinary.createUploader().signedUpload(
                data: imageData,
                params: params,
                progress: nil
            ) { response, error in
                if let error = error {
                    print("Error uploading to Cloudinary: \(error.localizedDescription)")
                } else if let response = response {
                    print("Successfully uploaded to Cloudinary in folder: \(folder)")
                    if let url = response.secureUrl {
                        print("Image URL: \(url)")
                    }
                }
                continuation.resume()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        return apiKey
    }
    
    private var cloudinaryCloudName: String {
        guard let cloudName = Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_CLOUD_NAME") as? String else {
            fatalError("CLOUDINARY_CLOUD_NAME not found in Info.plist")
        }
        return cloudName
    }
    
    private var cloudinaryApiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_API_KEY") as? String else {
            fatalError("CLOUDINARY_API_KEY not found in Info.plist")
        }
        return apiKey
    }
    
    private var cloudinaryApiSecret: String {
        guard let apiSecret = Bundle.main.object(forInfoDictionaryKey: "CLOUDINARY_API_SECRET") as? String else {
            fatalError("CLOUDINARY_API_SECRET not found in Info.plist")
        }
        return apiSecret
    }
}

