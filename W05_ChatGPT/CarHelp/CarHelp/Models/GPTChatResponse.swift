//
//  GPTChatResponse.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

struct GPTChatResponse: Codable {
  let id: String
  let created: Date
  let model: String
  let choices: [Choice]
  
  struct Choice: Codable {
    let message: Message
  }
}
