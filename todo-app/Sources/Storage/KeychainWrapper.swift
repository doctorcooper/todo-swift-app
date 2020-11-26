//
//  KeychainWrapper.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 10.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import KeychainAccess
import Foundation

@propertyWrapper
struct Keychain<T: Codable> {
    
    enum Key: String {
        case token
    }
    
    private let keychain: KeychainAccess.Keychain
    private let key: Key
    
    init(key: Key) {
        self.keychain = KeychainAccess.Keychain(service: Bundle.main.bundleIdentifier ?? "com.keychain.todo-app")
        self.key = key
    }
    
    var wrappedValue: T? {
        get {
            guard let data = try? keychain.getData(key.rawValue),
                let value = try? JSONDecoder().decode(T.self, from: data) else { return nil }
            return value
        }
        set {
            guard let newData = try? JSONEncoder().encode(newValue) else { return }
            try? keychain.set(newData, key: key.rawValue)
        }
    }
}
