//
//  NetworkProvider.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 07.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Moya
import RxMoya
import RxSwift
import Foundation

final class NetworkProvider {
    
    // MARK: - Private properties
    private let endpoints: MoyaProvider<NetworkEndpoints>
    
    // MARK: - Init
    init(endpoints: MoyaProvider<NetworkEndpoints>) {
        self.endpoints = endpoints
    }
    
    // MARK: - Internal methods
    // MARK: - Auth
    func login(login: String, password: String) -> Single<String> {
        return endpoints.rx.request(.login(login: login, password: password))
            .catchApiError(ErrorResponse.self)
            .mapString(atKeyPath: "token")
    }
    
    func logout() -> Single<Response> {
        return endpoints.rx.request(.logout)
            .catchApiError(ErrorResponse.self)
    }
    
    func register(login: String, password: String) -> Single<String> {
        return endpoints.rx.request(.register(login: login, password: password))
            .catchApiError(ErrorResponse.self)
            .mapString(atKeyPath: "token")
    }
    
    func getUser() -> Single<String> {
        return endpoints.rx.request(.me)
            .catchApiError(ErrorResponse.self)
            .mapString(atKeyPath: "email")
    }
    
    func getTasks() -> Single<[TodoItemDTO]> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return endpoints.rx.request(.getAllTasks)
            .catchApiError(ErrorResponse.self)
            .map([TodoItemDTO].self, using: decoder)
    }
    
    func uploadTask(item: TodoItemDTO) -> Single<Response> {
        return endpoints.rx.request(.postTask(item: item))
            .catchApiError(ErrorResponse.self)
    }
    
    func uploadTask(items: [TodoItemDTO]) -> Single<Response> {
        return endpoints.rx.request(.postTasks(items: items))
            .catchApiError(ErrorResponse.self)
    }
    
    func updateTask(id: String, item: TodoItemDTO) -> Single<Response> {
        return endpoints.rx.request(.updateTask(id: id, item: item))
            .catchApiError(ErrorResponse.self)
    }
    
    func deleteTask(id: String) -> Single<Response> {
        return endpoints.rx.request(.deleteTask(id: id))
            .catchApiError(ErrorResponse.self)
    }
}
