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
public typealias Task = protocol<TaskProtocol, TaskPolicy>

public enum Method: String {
    case GET, POST, PUT, PATCH, DELETE
}

public protocol TaskProtocol {
    var baseURL: String { get }
    var path: String { get }
    var headers: Headers { get }
    var parameters: Parameters { get }
    var method: Method { get }
    var token: String { get }
    func completed(withResponse response: HTTPResponse)
}

public extension TaskProtocol {
    
    var headers: [String: String] {
        get {
            return [:]
        }
    }
    
    var json: JSON {
        return [TaskConstants.baseURL.rawValue: baseURL,
                TaskConstants.path.rawValue: path,
                TaskConstants.headers.rawValue: headers,
                TaskConstants.parameters.rawValue: parameters,
                TaskConstants.method.rawValue: method.rawValue,
                TaskConstants.token.rawValue: token]
    }
    
    var method: Method {
        return .GET
    }
    
    var token: String {
        return "\(method) | \(path) | \(parameters)"
    }
}

public enum TaskConstants: String {
    case baseURL, path, headers, parameters, method, token, authenticated, persist
}

public protocol TaskPolicy {
    var authenticated: Bool { get }
    var persist: Bool { get }
}

public extension TaskPolicy {

    var authenticated: Bool {
        return false
    }
    
    var persist: Bool {
        return false
    }
}

public enum TaskPolicyConstants: String {
    case authenticated, enqueue, persist
}
