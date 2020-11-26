//
//  NetworkTarget.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 03.10.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import Moya
import Foundation

enum NetworkEndpoints {
    // MARK: - Auth
    case login(login: String, password: String)
    case logout
    case register(login: String, password: String)
    case me
    // MARK: - Tasks
    case getAllTasks
    case postTask(item: TodoItemDTO)
    case postTasks(items: [TodoItemDTO])
    case updateTask(id: String, item: TodoItemDTO)
    case deleteTask(id: String)
}

extension NetworkEndpoints: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: NetworkConstants.url)!
    }
    
    var path: String {
        let authPrefix = "/users"
        let taskPrefix = "/task"
        switch self {
            
        // MARK: - Auth
        case .login: return authPrefix + "/login"
        case .logout: return authPrefix + "/logout"
        case .register: return authPrefix + "/register"
        case .me: return authPrefix + "/me"
        // MARK: - Tasks
        case .getAllTasks: return taskPrefix
        case .postTask: return taskPrefix
        case .postTasks: return taskPrefix + "/list"
        case .updateTask(let id, _): return taskPrefix + "/\(id)"
        case .deleteTask(let id): return taskPrefix + "/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .me, .getAllTasks: return .get
        case .login, .logout, .register, .postTask, .postTasks: return .post
        case .updateTask: return .put
        case .deleteTask: return .delete
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let login, let password):
            let parameters: [String: Any] = ["email": login, "password": password]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .logout, .me, .getAllTasks, .deleteTask:
            return .requestPlain
        case .register(let login, let password):
            let parameters: [String: Any] = ["email": login, "password": password]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .postTask(let item), .updateTask(_, let item):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return .requestCustomJSONEncodable(item, encoder: encoder)
        case .postTasks(let items):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            return .requestCustomJSONEncodable(items, encoder: encoder)
        }
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .login, .register: return nil
        default: return .bearer
        }
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
