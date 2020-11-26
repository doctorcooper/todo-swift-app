//
//  Coordinatable.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 03.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Swinject
import UIKit

protocol Coordinatable {
    var navigationController: UINavigationController { get set }
    var container: Container { get }
    func start()
}
