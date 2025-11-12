//
//  Array+Ext.swift
//  CarHelp
//
//  Created by Dariy Kutelov on 10.11.25.
//

import Foundation

extension Array where Element == Message {
  static func makeContext(_ contents: String...) -> [Message] {
    return contents.map { Message(role: .system, content: $0)}
  }
}
