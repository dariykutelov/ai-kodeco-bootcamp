//
//  AccuracyLevel.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import Foundation

enum AccuracyLevel {
    case high        // 85-100%
    case medium      // 70-85%
    case low         // <70%
    
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

