//
//  Message.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//
import SwiftUI


// MARK: - Role Enum

enum Role: String, Codable {
    case assistant
    case system
    case user
}


// MARK: - Text Message

struct Message: Codable, Hashable {
    let role: Role
    let content: MessageContent
    
    init(role: Role, content: String) {
        self.role = role
        self.content = .text(content)
    }
    
    init(role: Role, contentItems: [ContentItem]) {
        self.role = role
        self.content = .items(contentItems)
    }
    
    static func withImage(role: Role, text: String?, imageUrl: String) -> Message {
        var items: [ContentItem] = []
        if let text = text, !text.isEmpty {
            items.append(.text(TextContent(text: text)))
        }
        items.append(.image(ImageContent(imageUrl: imageUrl)))
        return Message(role: role, contentItems: items)
    }
}


// MARK: - Message Content Enum

enum MessageContent: Codable, Hashable {
    case text(String)
    case items([ContentItem])
    
    var textValue: String {
        switch self {
        case .text(let string):
            return string
        case .items(let items):
            return items.compactMap { item in
                if case .text(let textContent) = item {
                    return textContent.text
                }
                return nil
            }.joined(separator: " ")
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .text(string)
        } else if let items = try? container.decode([ContentItem].self) {
            self = .items(items)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Content must be String or [ContentItem]")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let string):
            try container.encode(string)
        case .items(let items):
            try container.encode(items)
        }
    }
}


// MARK: - Content Item Enum

enum ContentItem: Codable, Hashable {
    case text(TextContent)
    case image(ImageContent)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "input_text":
            let text = try container.decode(String.self, forKey: .text)
            self = .text(TextContent(text: text))
        case "input_image":
            let imageUrl = try container.decode(String.self, forKey: .imageUrl)
            self = .image(ImageContent(imageUrl: imageUrl))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type: \(type)")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let textContent):
            try container.encode("input_text", forKey: .type)
            try container.encode(textContent.text, forKey: .text)
        case .image(let imageContent):
            try container.encode("input_image", forKey: .type)
            try container.encode(imageContent.imageUrl, forKey: .imageUrl)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
}


// MARK: - Text Content Struct

struct TextContent: Hashable {
    let text: String
}


// MARK: - Image Content Struct

struct ImageContent: Hashable {
    let imageUrl: String
}

