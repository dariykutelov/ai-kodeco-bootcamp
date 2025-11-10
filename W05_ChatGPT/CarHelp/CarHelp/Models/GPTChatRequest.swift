//
//  GPTChatRequest.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

struct GPTChatRequest: Codable {
    let model: GPTModelVersion
    let messages: [Message]
    
    init(model: GPTModelVersion,
         messages: [Message]) {
        self.model = model
        self.messages = messages
    }
}
