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
    
    // MARK: - Properties
    
    let breed: String
    var breedDetails: Breed?
    var errorMessage: String?
    var isUploading = false
    var apiImage: UIImage?
    
    private var cloudinary: CLDCloudinary {
        let config = CLDConfiguration(cloudName: cloudinaryCloudName, apiKey: cloudinaryApiKey, apiSecret: cloudinaryApiSecret)
        return CLDCloudinary(configuration: config)
    }
    
    
    // MARK: - Init
    
    init(breed: String) {
        self.breed = breed
        
        Task {
            await fetchBreedDetails()
        }
    }
    
    
    // MARK: - Fetching breed details from api
    
    private func fetchBreedDetails() async {
        guard let breedName =  Breeds(rawValue: breed)?.apiBreedName,
              let url = URL(string: "https://api.api-ninjas.com/v1/dogs?name=\(breedName)") else {
            print("Invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            let breeds = try JSONDecoder().decode([Breed].self, from: data)
            
            if breeds.isEmpty {
                self.errorMessage = "No breed details available"
            } else {
                let breed = breeds.first
                await MainActor.run {
                    self.apiImage = nil
                    self.breedDetails = breed
                }
                
                if let imageLink = breed?.imageLink, let url = URL(string: imageLink) {
                    await MainActor.run {
                        loadImage(from: url)
                    }
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
    // MARK: - Upload user image to cloud for retraining the model
    
    private func uploadToCloudinary(image: UIImage, folder: String) async {
        await MainActor.run {
            isUploading = true
        }
        
        defer {
            Task { @MainActor in
                isUploading = false
            }
        }
        
        let resizedImage = image.resizeTo360x360()
        
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
            ) { _, error in
                if let error = error {
                    print("Error uploading to Cloudinary: \(error.localizedDescription)")
                }
                
                continuation.resume()
            }
        }
    }
    
    
    // MARK: - Loading breed reference image
    
    func loadImage(from url: URL) {
        Task {
            await MainActor.run {
                self.apiImage = nil
            }
            do {
                var request = URLRequest(url: url)
                request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
                request.timeoutInterval = 30.0
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let image = UIImage(data: data) else {
                    return
                }
                
                await MainActor.run {
                    self.apiImage = image
                }
            } catch {
                return
            }
        }
    }
    
    
    // MARK: - Helper Methods
    
    func confirmUpload(image: UIImage?, folder: String) {
        guard let image = image else {
            print("No image to upload")
            return
        }
        
        Task {
            await uploadToCloudinary(image: image, folder: folder)
        }
    }
    
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

