//
//  UIKit+Assembly.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 12.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Swinject

struct AssemblyUIKit: Assembly {
    
    func assemble(container: Container) {
        container.register(Repository.self) { resolver in
            let repository = Repository()
            return repository
        }.inObjectScope(.container)
        
        registerViewModels(container)
        registerViewControllers(container)
    }
    
    private func registerViewModels(_ container: Container) {
        container.register(TodoListViewModel.self) { resolver in
            let vm = TodoListViewModel()
            let repository = resolver.resolve(Repository.self)
            vm.repository = repository
            return vm
        }
        
        container.register(MenuViewModel.self) { resolver in
            let vm = MenuViewModel()
            vm.networkProvider = resolver.resolve(NetworkProvider.self)
            vm.repository = resolver.resolve(Repository.self)
            return vm
        }
    }
    
    private func registerViewControllers(_ container: Container) {
        container.register(TodoListViewController.self) { resolver in
            let vm = resolver.resolve(TodoListViewModel.self)
            let vc = TodoListViewController()
            vc.viewModel = vm
            return vc
        }
        
        container.register(MenuViewController.self) { resolver in
            let vm = resolver.resolve(MenuViewModel.self)
            let vc = MenuViewController()
            vc.viewModel = vm
            return vc
        }
    }
}
