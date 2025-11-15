//
//  GPTChatRequest.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

struct GPTChatRequest: Codable {
    struct Tool: Codable {
        let type: String
    }
    
    let model: GPTModelVersion
    let input: [Message]
    let stream: Bool
    let tools: [Tool]?
    
    init(model: GPTModelVersion,
         messages: [Message],
         stream: Bool = false,
         tools: [Tool]? = nil) {
        self.model = model
        self.input = messages
        self.stream = stream
        self.tools = tools
    }
}
