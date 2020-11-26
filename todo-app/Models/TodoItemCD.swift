//
//  TodoItem+CoreDataClass.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 03.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//
//

import Foundation
import CoreData


public class TodoItem: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isDone: Bool
    @NSManaged public var createdAt: Date?
    
    class func create(in context: NSManagedObjectContext, item: TodoItemDTO) -> TodoItem {
        let cdItem = TodoItem(context: context)
        cdItem.id = item.id
        cdItem.title = item.title
        cdItem.isDone = item.isDone
        cdItem.createdAt = item.createdAt
        return cdItem
    }
}
