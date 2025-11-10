//
//  Message.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//
import SwiftUI

struct Message: Codable, Hashable {
    let role: Role
    let content: String
    let timestamp: Date?
    
    enum Role: String, Codable {
        case assistant
        case system
        case user
    }
}
