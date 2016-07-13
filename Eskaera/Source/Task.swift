//
//  Task.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public typealias JSON = [String: AnyObject]
public typealias Headers = [String: String]
public typealias Parameters = [String: String]

public enum Method: String {
    case GET, POST, PUT, PATCH, DELETE
}

public protocol Errorable {
    var errorsToSkip: [String: [String]] { get }
}

public protocol Task {
    
    var baseURL: String { get }
    var path: String { get }
    var headers: Headers { get }
    var parameters: Parameters { get }
    var method: Method { get }
    var token: String { get }
    var json: JSON { get }
    var authenticated: Bool { get }
    var persist: Bool { get }
    
    func completed(withResponse response: HTTPResponse)
}

public extension Task {
    
    var headers: [String: String] {
        return [:]
    }
    
    var json: JSON {
        return [TaskConstants.baseURL.rawValue: baseURL,
                TaskConstants.path.rawValue: path,
                TaskConstants.headers.rawValue: headers,
                TaskConstants.parameters.rawValue: parameters,
                TaskConstants.method.rawValue: method.rawValue,
                TaskConstants.token.rawValue: token,
                TaskConstants.authenticated.rawValue: authenticated,
                TaskConstants.persist.rawValue: persist
        ]
    }
    
    var method: Method {
        return .GET
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    var token: String {
        return "\(method) | \(path) | \(parameters)"
    }
    
    var authenticated: Bool {
        return true
    }
    
    var persist: Bool {
        return false
    }
}

public enum TaskConstants: String {
    case baseURL, path, headers, parameters, method, token, authenticated, persist
}
