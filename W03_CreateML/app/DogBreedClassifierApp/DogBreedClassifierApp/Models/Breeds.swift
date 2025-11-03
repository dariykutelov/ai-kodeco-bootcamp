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
    case beagle
    case blenheim_spaniel
    case blood_hound
    case border_collie
    case borzoi
    case boston_bulldog
    case boxer
    case chihuahua
    case chow
    case clumber
    case cocker_spaniel
    case coonhound
    case dachshund
    case dalmatian
    case dhole
    case dingo
    case doberman
    case english_setter
    case english_springer
    case english_hound
    case fox_terrier
    case french_bulldog
    case german_pointer
    case germanshepherd
    case golden_retriever
    case groenendael
    case husky
    case irish_setter
    case labrador
    case mexicanhairless
    case norwegian_elkhound
    case norwich_terrier
    case pembroke
    case pomeranian
    case rottweiler
    case shihtzu
    case standard_poodle
    case stbernard
    case yorkshire_terrier
    case vizsla
    case unknown
    
    // MARK: - api https://api-ninjas.com/api/dogs
    var apiBreedName: String {
        switch self {
        case .american_terrier:
            return "American Hairless Terrier"
        case .basset_hound:
            return "Basset Hound"
        case .beagle:
            return "Beagle"
        case .blenheim_spaniel:
            return "Cavalier King Charles Spaniel"
        case .blood_hound:
            return "Bloodhound"
        case .border_collie:
            return "Border Collie"
        case .borzoi:
            return "Borzoi"
        case .boston_bulldog:
            return "Boston Terrier"
        case .boxer:
            return "Boxer"
        case .chihuahua:
            return "Chihuahua"
        case .chow:
            return "Chow"
        case .clumber:
            return "Clumber Spaniel"
        case .cocker_spaniel:
            return "Cocker Spaniel"
        case .coonhound:
            return "American English Coonhound"
        case .dachshund:
            return "Dachshund"
        case .dalmatian:
            return "Dalmatian"
        case .dhole:
            return "Dhole"
        case .dingo:
            return "Dingo"
        case .doberman:
            return "Doberman Pinscher"
        case .english_hound:
            return "English Foxhound"
        case .english_setter:
            return "English Setter"
        case .english_springer:
            return "English Springer Spaniel"
        case .fox_terrier:
            return "Smooth Fox Terrier"
        case .french_bulldog:
            return "French Bulldog"
        case .german_pointer:
            return "Pointer"
        case .germanshepherd:
            return "German Shepherd Dog"
        case .golden_retriever:
            return "Golden Retriever"
        case .groenendael:
            return "Belgian Sheepdog"
        case .husky:
            return "Husky"
        case .irish_setter:
            return "Irish Setter"
        case .labrador:
            return "Labrador"
        case .mexicanhairless:
            return "Xoloitzcuintli"
        case .norwegian_elkhound:
            return "Norwegian Elkhound"
        case .norwich_terrier:
            return "Norwich Terrier"
        case .pembroke:
            return "Pembroke Welsh Corgi"
        case .pomeranian:
            return "pomeranian"
        case .rottweiler:
            return "Rottweiler"
        case .shihtzu:
            return "Shih Tzu"
        case .standard_poodle:
            return "Poodle (Standard)"
        case .stbernard:
            return "Saint Bernard"
        case .yorkshire_terrier:
            return "Yorkshire Terrier"
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
        case .beagle:
            return "Beagle"
        case .blenheim_spaniel:
            return "Cavalier King Charles Spaniel"
        case .blood_hound:
            return "Blood hound"
        case .border_collie:
            return "Border Collie"
        case .borzoi:
            return "Borzoi"
        case .boston_bulldog:
            return "Boston Bulldog/ Terrier"
        case .boxer:
            return "Boxer"
        case .chihuahua:
            return "Chihuahua"
        case .chow:
            return "Chow Chow"
        case .clumber:
            return "Clumber Spaniel"
        case .cocker_spaniel:
            return "Cocker Spaniel"
        case .coonhound:
            return "Coonhound"
        case .dachshund:
            return "Dachshund"
        case .dalmatian:
            return "Dalmatian"
        case .dhole:
            return "Dhole"
        case .dingo:
            return "Dingo"
        case .doberman:
            return "Doberman"
        case .english_hound:
            return "English Hound/ Foxhound"
        case .english_springer:
            return "English Springer"
        case .english_setter:
            return "English Setter"
        case .fox_terrier:
            return "Fox Terrier"
        case .french_bulldog:
            return "French Bulldog"
        case .german_pointer:
            return "German Pointer"
        case .germanshepherd:
            return "German Shepherd"
        case .golden_retriever:
            return "Golden Retriever"
        case .groenendael:
            return "Groenendael/ Belgian Sheepdog"
        case .husky:
            return "Husky"
        case .irish_setter:
            return "Irish Setter"
        case .labrador:
            return "Labrador"
        case .mexicanhairless:
            return "Xoloitzcuintli/ Mexican Hairless"
        case .norwegian_elkhound:
            return "Norwegian Elkhound"
        case .norwich_terrier:
            return "Norwich Terrier"
        case .pembroke:
            return "Pembroke Welsh Corgi"
        case .pomeranian:
            return "Pomeranian"
        case .rottweiler:
            return "Rottweiler"
        case .shihtzu:
            return "Shih Tzu"
        case .standard_poodle:
            return "Poodle"
        case .stbernard:
            return "Saint Bernard"
        case .yorkshire_terrier:
            return "Yorkshire Terrier"
        case .vizsla:
            return "Vizsla"
        case .unknown:
            return "Unkown breed"
        }
    }
}
