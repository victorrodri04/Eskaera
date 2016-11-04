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

public protocol ErrorSkipable {
    func shoulPersistTask(with failureResponseData: Data) -> Bool
}

public protocol Task {
    
    var baseURL: String { get }
    var path: String { get }
    var headers: Headers { get }
    var parameters: Parameters { get }
    var method: Method { get }
    var identifier: String { get }
    var json: JSON { get }
    var authenticated: Bool { get }
    var authorizationType: String { get }
    var persist: Bool { get }
    
    func completed(with response: HTTPResponse)
}

public extension Task {
    
    var headers: [String: String] {
        return [:]
    }
    
    var json: JSON {
        return [TaskConstants.baseURL.rawValue: baseURL as AnyObject,
                TaskConstants.path.rawValue: path as AnyObject,
                TaskConstants.headers.rawValue: headers as AnyObject,
                TaskConstants.parameters.rawValue: parameters as AnyObject,
                TaskConstants.method.rawValue: method.rawValue as AnyObject,
                TaskConstants.identifier.rawValue: identifier as AnyObject,
                TaskConstants.authenticated.rawValue: authenticated as AnyObject,
                TaskConstants.authorizationType.rawValue: authorizationType as AnyObject,
                TaskConstants.persist.rawValue: persist as AnyObject
        ]
    }
    
    var method: Method {
        return .GET
    }
    
    var parameters: Parameters {
        return Parameters()
    }
    
    var identifier: String {
        return "\(method) | \(path) | \(parameters)"
    }
    
    var authenticated: Bool {
        return true
    }
    
    var authorizationType: String {
        return "Bearer "
    }
    
    var persist: Bool {
        return false
    }
}

enum TaskConstants: String {
    case baseURL, path, headers, parameters, method, identifier, authenticated, authorizationType, persist
}
