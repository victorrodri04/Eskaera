//
//  Task.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public typealias JSON = [String: AnyObject]

public enum Method: String {
    case GET, POST, PUT, PATCH, DELETE
}

public protocol Task {
    var baseURL: String { get }
    var path: String { get }
    var headers: [String: String] { get }
    var parameters: JSON { get }
    var method: Method { get }
    var enqueue: Bool { get }
    var token: String { get }
    var authenticated: Bool { get }
    func completed(withResponseData data: NSData)
    func completed(withError error: ErrorType)
}

public extension Task {
    
    var headers: [String: String] {
        return [:]
    }
    
    var parameters: JSON {
        return [:]
    }
    
    var method: Method {
        return .GET
    }
    
    var enqueue: Bool {
        return true
    }
    
    var token: String {
        return "\(method) | \(path) | \(parameters)"
    }
    
    var authenticated: Bool {
        return false
    }
}
