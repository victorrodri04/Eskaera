//
//  HTTPClient.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation
import UIKit

open class HTTPClient {
    
    open static let sharedInstance = HTTPClient()
    
    fileprivate var session: URLSession
    open var token: String?
    
    public init(configuration: URLSessionConfiguration = URLSessionConfiguration.default,
                token: String? = nil) {
        self.session = URLSession(configuration: configuration)
        self.token = token
    }
    
    open func request(_ request: Request, completion: @escaping (HTTPResponse) -> Void) {
        
        var taskJSON: JSON?
        
        if let task = request.task {
            taskJSON = task.json
        } else if let dictionary = request.taskDictionary {
            taskJSON = dictionary
        }
        
        guard let json = taskJSON, let urlRequest = createRequest(with: json) else {
            completion(HTTPResponse.failure(HTTPResponse.error.system))
            return
        }
        
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            
            if let error = error {
                return completion(HTTPResponse.failure(HTTPResponse.error.other(error)))
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(HTTPResponse.failure(HTTPResponse.error.couldNotGetResponse))
                return
            }
            
            if 200 ..< 300 ~= httpResponse.statusCode {
                completion(HTTPResponse.success(data))
            } else {
                completion(HTTPResponse.failure(HTTPResponse.error.resquest(data: data)))
            }
        }) 
        
        task.resume()
    }
    
    fileprivate func createRequest(with taskJSON: JSON) -> URLRequest? {
        
        guard
            let urlString = taskJSON[TaskConstants.baseURL.rawValue] as? String,
            let baseURL = Foundation.URL(string: urlString),
            let path = taskJSON[TaskConstants.path.rawValue] as? String,
            let methodString = taskJSON[TaskConstants.method.rawValue] as? String,
            let method = Method(rawValue: methodString),
            let parameters = taskJSON[TaskConstants.parameters.rawValue] as? Parameters,
            let authenticated = taskJSON[TaskConstants.authenticated.rawValue] as? Bool,
            let authorizationType = taskJSON[TaskConstants.authorizationType.rawValue] as? String,
            let headers = taskJSON[TaskConstants.headers.rawValue] as? Headers
        else {
            return nil
        }
        
        let URL = baseURL.appendingPathComponent(path)
        
        guard
            var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)
        else {
            return nil
        }
        
        let queryItems = parameters.map {
            URLQueryItem(name: String($0), value: String($1))
        }
        
        let request = NSMutableURLRequest()
        request.httpMethod = method.rawValue
        
        switch method {
        case .GET:
            components.queryItems = queryItems
        case .POST:
            var postComponents = URLComponents()
            postComponents.queryItems = queryItems
            request.httpBody = postComponents.percentEncodedQuery?.data(using: String.Encoding.utf8)
        default:
            break
        }
        
        guard let finalURL = components.url else {
            return nil
        }
        
        request.url = finalURL
        request.allHTTPHeaderFields = headers
        
        if authenticated, let token = token {
            var headers = headers
            headers["Authorization"] = authorizationType + token
            request.allHTTPHeaderFields = headers
        }
        
        return request as URLRequest
    }
}
