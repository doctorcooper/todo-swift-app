//
//  TodoListViewController.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 23.09.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol TodoListCoordinator: AnyObject {
    func menuDidTapped()
}

final class TodoListViewController: UIViewController {
    
    // MARK: - Constants
    private struct Constants {
        static let title = "UIKit Todo List"
        static let menuButtonText = "Menu"
        static let cellIdentifier = "Cell"
        static let alertTitle = "New Item"
        static let alertMessage = "Enter the description of task"
        static let alertOkButtonText = "Save"
        static let alertCancelButtonText = "Cancel"
    }
    
    // MARK: - Outlets
    @IBOutlet weak private var tableView: UITableView!
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let menuButton = UIBarButtonItem(title: Constants.menuButtonText,
                                             style: .plain,
                                             target: self,
                                             action: nil)
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: nil)
    
    // MARK: - Internal properties
    weak var coordinator: TodoListCoordinator?
    var viewModel: TodoListViewModel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppearEvent()
    }
    
    // MARK: - Private methods
    private func setupUI() {
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = addButton
        title = Constants.title
        
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: Constants.cellIdentifier)
    }
    
    private func setupBinding() {
        viewModel.bind()
        
        menuButton.rx.tap
            .subscribe { [weak self] _ in
                self?.coordinator?.menuDidTapped()
        }.disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe { [weak self] _ in
                self?.addItemTapped()
        }.disposed(by: disposeBag)
        
        // Workaround for RxCocoa tableview warning
        // https://github.com/RxSwiftCommunity/RxDataSources/issues/331
        DispatchQueue.main.async {
            self.viewModel.items
                .bind(to: self.tableView.rx.items(cellIdentifier: Constants.cellIdentifier,
                                                  cellType: UITableViewCell.self))
                { _, model, cell in
                    cell.textLabel?.text = model.title
                    cell.accessoryType = model.isDone ? .checkmark : .none
                    cell.selectionStyle = .none
            }.disposed(by: self.disposeBag)
        }
        
        tableView.rx.modelSelected(TodoItem.self)
            .subscribe (onNext: { [weak self] item in
                self?.viewModel.markItem(item: item)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                self?.viewModel.deleteItem(row: indexPath.row)
            }).disposed(by: disposeBag)
    }
    
    private func addItemTapped() {
        let alertVC = UIAlertController(title: Constants.alertTitle,
                                        message: Constants.alertMessage,
                                        preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: Constants.alertOkButtonText,
                                       style: .default) { [weak self] action in
                                        guard let textfield = alertVC.textFields?.first,
                                            let description = textfield.text else { return }
                                        self?.viewModel.addItem(item: description)
        }
        let cancelAction = UIAlertAction(title: Constants.alertCancelButtonText,
                                         style: .cancel,
                                         handler: nil)
        alertVC.addTextField()
        alertVC.addAction(saveAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
