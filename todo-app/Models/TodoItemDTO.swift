//
//  TodoItem.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 23.09.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Foundation

struct TodoItemDTO: Codable {
    let id: UUID
    let title: String
    let isDone: Bool
    let createdAt: Date
    
    init(from cdItem: TodoItem) {
        self.id = cdItem.id ?? UUID()
        self.title = cdItem.title ?? ""
        self.isDone = cdItem.isDone
        self.createdAt = cdItem.createdAt ?? Date()
    }
}
