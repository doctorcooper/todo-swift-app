//
//  NetworkError.swift
//  todo-app
//
//  Created by Dmitry Kupriyanov on 11.11.2020.
//  Copyright © 2020 Dmitry Kupriyanov. All rights reserved.
//

import RxSwift
import Moya
import Foundation

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func catchApiError(_ type: ErrorResponse.Type) -> Single<Element> {
        return flatMap { response in
            guard (200 ... 299).contains(response.statusCode) else {
                do {
                    let apiError = try response.map(type.self)
                    throw ApiError(message: apiError.reason)
                } catch {
                    throw error
                }
            }
            return .just(response)
        }
    }
}

struct ErrorResponse: Decodable {
    let error: Bool
    let reason: String
}

enum ApiError: Error {
    case unknown
    case unauthorized
    case with(message: String)
    
    init(message: String) {
        switch message {
        case "Unauthorized": self = .unauthorized
        
        default:
            self = message.isEmpty ? .unknown : .with(message: message)
        }
    }
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
            
        case .unknown:
            return NSLocalizedString("An unknown error occured", comment: "")
        case .unauthorized:
            return NSLocalizedString("Wrong email or password", comment: "")
        case .with(let message):
            return NSLocalizedString("Error: \(message)", comment: "")
        }
    }
}
