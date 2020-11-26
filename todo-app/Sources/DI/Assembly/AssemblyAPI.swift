//
//  API+Assembly.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 11.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Swinject
import Moya

final class AssemblyAPI: Assembly {
    @Keychain<String>(key: .token)
    private var token
    
    
    
    func assemble(container: Container) {
        container.register(NetworkProvider.self) { _ in
            var logger: NetworkLoggerPlugin {
                var configuration = NetworkLoggerPlugin.Configuration()
                configuration.logOptions = .verbose
                
                let networkLoggerPlugin = NetworkLoggerPlugin(configuration: configuration)
                return networkLoggerPlugin
            }
            
            let tokenClosure: ((AuthorizationType) -> String) = { [weak self] _ in
                return self?.token ?? ""
            }
            
            let endpoints = MoyaProvider<NetworkEndpoints>(plugins: [logger, AccessTokenPlugin(tokenClosure: tokenClosure)])
            
            return NetworkProvider(endpoints: endpoints)
        }
    }
}
