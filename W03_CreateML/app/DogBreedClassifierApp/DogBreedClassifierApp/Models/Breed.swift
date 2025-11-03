//
//  Breed.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 29.10.25.
//

import Foundation

struct Breed: Decodable, Equatable {
    let imageLink: String
    let goodWithChildren: Int
    let goodWithOtherDogs: Int
    let shedding: Int
    let grooming: Int
    let drooling: Int
    let coatLength: Int
    let goodWithStrangers: Int
    let playfulness: Int
    let protectiveness: Int
    let trainability: Int
    let energy: Int
    let barking: Int
    let minLifeExpectancy: Double
    let maxLifeExpectancy: Double
    let maxHeightMale: Double
    let maxHeightFemale: Double
    let maxWeightMale: Double
    let maxWeightFemale: Double
    let minHeightMale: Double
    let minHeightFemale: Double
    let minWeightMale: Double
    let minWeightFemale: Double
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case imageLink = "image_link"
        case goodWithChildren = "good_with_children"
        case goodWithOtherDogs = "good_with_other_dogs"
        case shedding
        case grooming
        case drooling
        case coatLength = "coat_length"
        case goodWithStrangers = "good_with_strangers"
        case playfulness
        case protectiveness
        case trainability
        case energy
        case barking
        case minLifeExpectancy = "min_life_expectancy"
        case maxLifeExpectancy = "max_life_expectancy"
        case maxHeightMale = "max_height_male"
        case maxHeightFemale = "max_height_female"
        case maxWeightMale = "max_weight_male"
        case maxWeightFemale = "max_weight_female"
        case minHeightMale = "min_height_male"
        case minHeightFemale = "min_height_female"
        case minWeightMale = "min_weight_male"
        case minWeightFemale = "min_weight_female"
        case name
    }
}
