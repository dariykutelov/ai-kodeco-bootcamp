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
}
