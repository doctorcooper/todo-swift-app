//
//  TodoListViewModel.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 11.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import RxCocoa
import RxSwift
import Foundation

final class TodoListViewModel {
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Internal properties
    var repository: Repository!
    let items = BehaviorRelay<[TodoItem]>(value: [])
    
    // MARK: - Internal methods
    func viewWillAppearEvent() {
        repository.getAll()
    }
    
    func addItem(item: String) {
        repository.addItem(title: item)
    }
    
    func markItem(item: TodoItem) {
        if let id = item.id {
            repository.updateItem(uuid: id, isDone: !item.isDone)
        }
    }
    
    func deleteItem(row: Int) {
        if let id = repository.output[row].id {
            repository.deleteItem(uuid: id)
        }
    }
    
    func bind() {
        repository.didUpdateEvent = { [weak self] (items) in
            self?.items.accept(items.sorted(by: { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }))
        }
    }
}
