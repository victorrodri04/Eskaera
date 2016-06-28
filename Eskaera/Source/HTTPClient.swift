//
//  HTTPClient.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation
import UIKit

public class HTTPClient {
    
    public static let sharedInstance = HTTPClient()
    
    private var session: NSURLSession
    public var token: String?
    
    public init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(),
                token: String? = nil) {
        self.session = NSURLSession(configuration: configuration)
        self.token = token
    }
    
    public func request(request: Request, completion: HTTPResponse -> Void) {
        
        var taskJSON: JSON?
        
        if let task = request.task {
            taskJSON = task.json
        } else if let dictionary = request.taskDictionary {
            taskJSON = dictionary
        }
        
        guard let json = taskJSON, urlRequest = createRequest(withTaskJSON: json) else {
            completion(HTTPResponse.Failure(HTTPResponse.Error.SystemError))
            return
        }
        
        let task = session.dataTaskWithRequest(urlRequest) { data, response, error in
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                completion(HTTPResponse.Failure(HTTPResponse.Error.CouldNotGetResponse))
                return
            }
            
            if 200 ..< 300 ~= httpResponse.statusCode {
                guard let data = data else {
                    completion(HTTPResponse.Failure(HTTPResponse.Error.Other(error)))
                    return
                }
                
                completion(HTTPResponse.Success(data))
            } else {
                completion(HTTPResponse.Failure(HTTPResponse.Error.BadStatus(status: httpResponse.statusCode)))
            }
        }
        
        task.resume()
    }
    
    private func createRequest(withTaskJSON taskJSON: JSON) -> NSURLRequest? {
        
        guard let urlString = taskJSON[TaskConstants.baseURL.rawValue] as? String,
            baseURL = NSURL(string: urlString),
            path = taskJSON[TaskConstants.path.rawValue] as? String,
            methodString = taskJSON[TaskConstants.method.rawValue] as? String,
            method = Method(rawValue: methodString),
            parameters = taskJSON[TaskConstants.parameters.rawValue] as? Parameters,
            authenticated = taskJSON[TaskConstants.authenticated.rawValue] as? Bool,
            headers = taskJSON[TaskConstants.headers.rawValue] as? Headers
            else { return nil }
        
        let URL = baseURL.URLByAppendingPathComponent(path)
        
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        let queryItems = parameters.map {
            NSURLQueryItem(name: String($0), value: String($1))
        }
        
        let request = NSMutableURLRequest()
        request.HTTPMethod = method.rawValue
        
        switch method {
        case .GET:
            components.queryItems = queryItems
        case .POST:
            let postComponents = NSURLComponents()
            postComponents.queryItems = queryItems
            request.HTTPBody = postComponents.percentEncodedQuery?.dataUsingEncoding(NSUTF8StringEncoding)
        default:
            break
        }
        
        guard let finalURL = components.URL else {
            return nil
        }
        
        request.URL = finalURL
        
        if authenticated, let token = token {
            var headers = headers
            headers["Authorization"] = "Bearer \(token)"
            request.allHTTPHeaderFields = headers
        }
        
        return request
    }
}
