//
//  Breeds.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import Foundation

enum Breeds: String {
    case american_terrier
    case basset_hound
    case chihuahua
    case germanshepherd
    case pomeranian
    case vizsla
    case unknown
    
    
    var apiBreedName: String {
        switch self {
        case .american_terrier:
            return "American Hairless Terrier"
        case .basset_hound:
            return "Basset Hound"
        case .chihuahua:
            return "Chihuahua"
        case .germanshepherd:
            return "German Shepherd Dog"
        case .pomeranian:
            return "pomeranian"
        case .vizsla:
            return "Vizsla"
        case .unknown:
            return "Unkown breed"
        }
    }
    
    var displayName: String {
        switch self {
        case .american_terrier:
            return "American Terrier"
        case .basset_hound:
            return "Basset Hound"
        case .chihuahua:
            return "Chihuahua"
        case .germanshepherd:
            return "German Shepherd"
        case .pomeranian:
            return "Pomeranian"
        case .vizsla:
            return "Vizsla"
        case .unknown:
            return "Unkown breed"
        }
    }
}
