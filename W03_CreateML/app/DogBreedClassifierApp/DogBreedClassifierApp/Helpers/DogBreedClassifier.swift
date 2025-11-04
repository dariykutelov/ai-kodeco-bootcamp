//
//  DogBreedClassifier.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import SwiftUI
import Vision
import CoreML

class DogBreedClassifier {
    private var model: VNCoreMLModel
    
    init() {
        let configuration = MLModelConfiguration()
        guard let mlModel = try? DogBreedClassifier42(configuration: configuration).model else {
            fatalError("Failed to load model")
        }
        
        self.model = try! VNCoreMLModel(for: mlModel)
    }
    
    func classify(image: UIImage) async throws -> (String?, Float?) {
        let resizedImage = image.resizeTo360x360()
        
        guard let ciImage = CIImage(image: resizedImage) else {
            throw ClassificationError.imageConversionFailed
        }
        
        let model = self.model
        return try await Task.detached(priority: .userInitiated) {
            let request = VNCoreMLRequest(model: model)
            let handler = VNImageRequestHandler(ciImage: ciImage)
            
            do {
                try handler.perform([request])
                
                guard let results = request.results as? [VNClassificationObservation] else {
                    throw ClassificationError.noResultsFound
                }
                
                guard let bestResult = results.max(by: { a, b in a.confidence < b.confidence }) else {
                    throw ClassificationError.noTopResultFound
                }
                
                return (bestResult.identifier, bestResult.confidence)
            } catch let error as ClassificationError {
                throw error
            } catch {
                throw ClassificationError.classificationFailed(error)
            }
        }.value
    }
}
