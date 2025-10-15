//
//  Task.swift
//  ToDoListTranslate
//
//  Created by Dariy Kutelov on 13.10.25.
//

import Foundation

struct ToDoTask: Identifiable, Codable {
    let id: String?
    var title: String
    var description: String
    var status: ToDoTaskStatus
    let priority: ToDoTaskPriority
    let createdAt: Date
    var dueDate: Date?
}


enum ToDoTaskStatus: Codable {
    case pending
    case inProgress
    case completed
    case cancelled
}

enum ToDoTaskPriority: Codable {
    case low
    case medium
    case high
}
