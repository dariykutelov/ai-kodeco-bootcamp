//
//  GPTModels.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

enum GPTModelVersion: String, Codable {
    /// Training data is up to Sep 2021
    case gpt35Turbo = "gpt-3.5-turbo"
    
    /// Training data is up to Oct 2023
    case gpt4o = "gpt-4o"
    
    /// Training data is up to Dec 2023
    case gpt4Turbo = "gpt-4-turbo"
    
    /// Training data is up to Apr 2024
    case gpt41mini = "gpt-4.1-mini"
    
    var contextTresouldLimit: Int {
        switch self {
        case .gpt35Turbo:
            return 4096
        case .gpt4o:
            return 8192
        case .gpt4Turbo:
            return 128000
        case .gpt41mini:
            //return 262144
            return 100
        }
        
    }
}
