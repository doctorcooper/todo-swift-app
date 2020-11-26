//
//  AppCoordinator.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 03.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import UIKit
import Swinject
import SwiftUI

final class AppCoordinator: Coordinatable {
    
    private enum Child {
        case uikit
        case swiftUI
    }
    private var childCoordinators: [Child: Coordinatable] = [:]
    
    var navigationController: UINavigationController
    var container: Container
    var tabBarController: UITabBarController
    
    init(container: Container, window: UIWindow?) {
        self.container = container
        self.navigationController = UINavigationController()
        self.tabBarController = UITabBarController()
        window?.rootViewController = tabBarController
    }
    
    func start() {
        let uiKitCoordinator = UIKitCoordinator(container: container,
                                                navigationController: UINavigationController())
        childCoordinators[.uikit] = uiKitCoordinator
        var vc: UIViewController
        if #available(iOS 13, *) {
            vc = UIHostingController(rootView: Text("Hello"))
            vc.title = "Swift ui"
        } else {
            vc = UIViewController()
            vc.title = "Temp"
        }
        
        tabBarController.setViewControllers([uiKitCoordinator.navigationController, vc], animated: true)
        childCoordinators[.uikit]?.start()
    }
}
