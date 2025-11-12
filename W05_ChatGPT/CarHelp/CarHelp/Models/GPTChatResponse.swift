//
//  GPTChatResponse.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

// TODO: - Change naming for non streaming response
struct GPTChatResponse: Codable {
    struct OutputItem: Codable {
        struct Content: Codable {
            let type: String
            let text: String?
        }
        
        let id: String
        let type: String
        let status: String?
        let role: Message.Role?
        let content: [Content]
    }
    
    struct Usage: Codable {
        struct TokensDetails: Codable {
            let cachedTokens: Int?
            
            enum CodingKeys: String, CodingKey {
                case cachedTokens = "cached_tokens"
            }
        }
        
        let inputTokens: Int?
        let outputTokens: Int?
        let totalTokens: Int?
        let inputTokensDetails: TokensDetails?
        let outputTokensDetails: TokensDetails?
        
        enum CodingKeys: String, CodingKey {
            case inputTokens = "input_tokens"
            case outputTokens = "output_tokens"
            case totalTokens = "total_tokens"
            case inputTokensDetails = "input_tokens_details"
            case outputTokensDetails = "output_tokens_details"
        }
    }
    
    let id: String
    let object: String?
    let createdAt: Int?
    let model: String
    let output: [OutputItem]
    let usage: Usage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case object
        case createdAt = "created_at"
        case model
        case output
        case usage
    }
}
