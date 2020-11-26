//
//  Repository.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 03.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

// TODO: - Need a single source of true
// One prop which give all enities.
// Here need a network provider, which update entities.

final class Repository {
    
    // MARK: - Private properties
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { return container.viewContext }
    private let disposeBag = DisposeBag()
    
    // MARK: - Internal Properties
    struct Constants {
        static let modelName: String = "TodoItem"
    }
        
    var didUpdateEvent: (([TodoItem]) -> Void)?
    var output = [TodoItem]() {
        didSet {
            didUpdateEvent?(output)
        }
    }
    
    // MARK: - Init
    init(modelName: String = Constants.modelName) {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        self.container = container
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contextDidChange(_:)),
                                               name: Notification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - CRUD Operations
    func addItem(title: String) {
        let item = TodoItem(context: context)
        item.id = UUID()
        item.title = title
        item.isDone = false
        item.createdAt = Date()
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                print("Save failed")
            }
        }
    }
    
    func addItems(items: [TodoItemDTO]) { 
        guard !items.isEmpty else { return }
        
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        let foundedItems = try? context.fetch(request)
        
        foundedItems?.forEach { item in
            context.delete(item)
        }
        
        items.forEach { (itemDTO) in
            let _ = TodoItem.create(in: context, item: itemDTO)
        }
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                print("Save failed")
            }
        }
    }
    
    @discardableResult
    func getAll() -> [TodoItem] {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(TodoItem.createdAt), ascending: false)
        request.sortDescriptors = [sort]
        do {
            let items = try context.fetch(request)
            self.output = items
            return items
        }
        catch {
            print("Get items failed")
            return []
        }
    }
    
    func deleteItem(uuid: UUID) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", uuid.uuidString)
        
        do {
            guard let foundedItem = try context.fetch(request).first else { return }
            context.delete(foundedItem)
            try context.save()
        }
        catch {
            print("Delete failed")
        }
    }
    
    func updateItem(uuid: UUID, isDone: Bool) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", uuid.uuidString)
        
        do {
            guard let foundedItem = try context.fetch(request).first else { return }
            foundedItem.isDone = isDone
            try context.save()
        }
        catch {
            print("Update failed")
        }
    }
    
    // MARK: - Private methods
    @objc
    private func contextDidChange(_ notification: Notification) {
        getAll()
    }
}
