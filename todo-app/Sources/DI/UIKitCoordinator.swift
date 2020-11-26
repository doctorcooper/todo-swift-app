//
//  UIKitCoordinator.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 12.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import UIKit
import Swinject

final class UIKitCoordinator: Coordinatable {
    var navigationController: UINavigationController
    var container: Container
    
    init(container: Container, navigationController: UINavigationController) {
        self.container = container
        self.navigationController = navigationController
    }
    
    func start() {
        guard let vc = container.resolve(TodoListViewController.self) else { return }
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: true)
    }
}

extension UIKitCoordinator: TodoListCoordinator {
    func menuDidTapped() {
        guard let vc = container.resolve(MenuViewController.self) else { return }
        vc.coordinator = self
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navigationController.present(navVC, animated: true, completion: nil)
    }
}

extension UIKitCoordinator: MenuCoordinator {
    func closeButtonTapped() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
