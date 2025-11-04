//
//  AccuracyLevel.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import Foundation

enum AccuracyLevel {
    case high
    case medium
    case low
    
    init(percentage: Float) {
        if percentage >= 85 {
            self = .high
        } else if percentage >= 70 {
            self = .medium
        } else {
            self = .low
        }
    }
}

