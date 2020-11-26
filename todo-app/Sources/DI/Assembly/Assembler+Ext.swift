//
//  Assembly+Ext.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 12.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Swinject

extension Assembler {
    static let shared: Assembler = {
        let container = Container()
        let assembler = Assembler([
            AssemblyAPI(),
            AssemblyUIKit()
        ], container: container)
        
        return assembler
    }()
}
