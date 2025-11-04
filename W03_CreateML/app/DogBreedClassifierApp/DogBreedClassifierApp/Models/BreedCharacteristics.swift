//
//  BreedCharacteristics.swift
//  DogBreedClassifierApp
//
//  Created by Dariy Kutelov on 2.11.25.
//

import Foundation

extension Breed {
    
    struct Characteristic {
        let title: String
        let description: String
        let icon: String
    }
    
    var characteristics: [Characteristic] {
        var traits: [Characteristic] = []
        
        traits.append(Characteristic(
            title: "Barking",
            description: describeTrait(value: barking, traitName: "barks", inverse: false),
            icon: "speaker.wave.3"
        ))
        
        traits.append(Characteristic(
            title: "Energy Level",
            description: describeTrait(value: energy, traitName: "energetic", inverse: false),
            icon: "bolt.fill"
        ))
        
        traits.append(Characteristic(
            title: "Playfulness",
            description: describeTrait(value: playfulness, traitName: "playful", inverse: false),
            icon: "figure.play"
        ))
        
        traits.append(Characteristic(
            title: "Trainability",
            description: describeTrait(value: trainability, traitName: "trainable", inverse: false),
            icon: "brain.head.profile"
        ))
        
        traits.append(Characteristic(
            title: "Protectiveness",
            description: describeTrait(value: protectiveness, traitName: "protective", inverse: false),
            icon: "shield.fill"
        ))
        
        traits.append(Characteristic(
            title: "Grooming Needs",
            description: describeTrait(value: grooming, traitName: "grooming", inverse: false),
            icon: "scissors"
        ))
        
        traits.append(Characteristic(
            title: "Shedding",
            description: describeTrait(value: shedding, traitName: "sheds", inverse: false),
            icon: "wind"
        ))
        
        traits.append(Characteristic(
            title: "Drooling",
            description: describeTrait(value: drooling, traitName: "drools", inverse: false),
            icon: "drop.fill"
        ))
        
        traits.append(Characteristic(
            title: "Good with Children",
            description: describeTrait(value: goodWithChildren, traitName: "good with children", inverse: true),
            icon: "figure.child"
        ))
        
        traits.append(Characteristic(
            title: "Good with Other Dogs",
            description: describeTrait(value: goodWithOtherDogs, traitName: "good with other dogs", inverse: true),
            icon: "pawprint.fill"
        ))
        
        traits.append(Characteristic(
            title: "Good with Strangers",
            description: describeTrait(value: goodWithStrangers, traitName: "good with strangers", inverse: true),
            icon: "person.2.fill"
        ))
        
        traits.append(Characteristic(
            title: "Coat Length",
            description: describeCoatLength(),
            icon: "square.stack.fill"
        ))
        
        traits.append(Characteristic(
            title: "Life Expectancy",
            description: "\(Int(minLifeExpectancy))-\(Int(maxLifeExpectancy)) years",
            icon: "heart.fill"
        ))
        
        traits.append(Characteristic(
            title: "Size",
            description: describeSize(),
            icon: "ruler.fill"
        ))
        
        return traits
    }
    
    private func describeTrait(value: Int, traitName: String, inverse: Bool) -> String {
        switch value {
        case 1:
            if inverse {
                return "Not very \(traitName)"
            } else {
                return "Minimal \(traitName)"
            }
        case 2:
            if inverse {
                return "Somewhat \(traitName)"
            } else {
                return "Low \(traitName)"
            }
        case 3:
            return "Average \(traitName)"
        case 4:
            if inverse {
                return "Very \(traitName)"
            } else {
                return "More than average \(traitName)"
            }
        case 5:
            if inverse {
                return "Excellent with \(traitName)"
            } else {
                return "Very high \(traitName)"
            }
        default:
            return "Average \(traitName)"
        }
    }
    
    private func describeCoatLength() -> String {
        switch coatLength {
        case 1:
            return "Very short coat"
        case 2:
            return "Short coat"
        case 3:
            return "Medium length coat"
        case 4:
            return "Long coat"
        case 5:
            return "Very long coat"
        default:
            return "Variable coat length"
        }
    }
    
    private func describeSize() -> String {
        let avgWeight = (minWeightMale + minWeightFemale + maxWeightMale + maxWeightFemale) / 4.0
        let avgHeight = (minHeightMale + minHeightFemale + maxHeightMale + maxHeightFemale) / 4.0
        
        if avgWeight < 10 && avgHeight < 10 {
            return "Very small (\(Int(avgWeight))-\(Int((maxWeightMale + maxWeightFemale) / 2)) lbs)"
        } else if avgWeight < 25 && avgHeight < 15 {
            return "Small (\(Int(avgWeight))-\(Int((maxWeightMale + maxWeightFemale) / 2)) lbs)"
        } else if avgWeight < 50 && avgHeight < 22 {
            return "Medium (\(Int(avgWeight))-\(Int((maxWeightMale + maxWeightFemale) / 2)) lbs)"
        } else if avgWeight < 80 && avgHeight < 27 {
            return "Large (\(Int(avgWeight))-\(Int((maxWeightMale + maxWeightFemale) / 2)) lbs)"
        } else {
            return "Very large (\(Int(avgWeight))-\(Int((maxWeightMale + maxWeightFemale) / 2)) lbs)"
        }
    }
}

