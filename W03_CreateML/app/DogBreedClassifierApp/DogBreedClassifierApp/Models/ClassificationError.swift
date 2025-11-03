//
//  ClassificationError.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import Foundation

enum ClassificationError: LocalizedError {
    case imageConversionFailed
    case noResultsFound
    case noTopResultFound
    case classificationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to CIImage"
        case .noResultsFound:
            return "No results found"
        case .noTopResultFound:
            return "No top result found"
        case .classificationFailed(let error):
            return "Failed to perform classification: \(error.localizedDescription)"
        }
    }
}
