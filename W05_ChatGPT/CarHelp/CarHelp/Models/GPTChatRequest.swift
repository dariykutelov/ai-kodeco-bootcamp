//
//  GPTChatRequest.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

struct GPTChatRequest: Codable {
    let model: GPTModelVersion
    let input: [Message]
    let stream: Bool
    
    init(model: GPTModelVersion,
         messages: [Message],
         stream: Bool = false) {
        self.model = model
        self.input = messages
        self.stream = stream
    }
}
