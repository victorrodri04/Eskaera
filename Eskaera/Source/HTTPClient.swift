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
    
    private func request(withTask task: Task) -> NSURLRequest? {
        
        guard let baseURL = NSURL(string: task.baseURL) else { return nil }
        let URL = baseURL.URLByAppendingPathComponent(task.path)
        
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        var queryItems: [NSURLQueryItem]?
        var queryString: NSData?
        
        switch task.method {
        case .GET:
            queryItems = task.parameters.map {
                NSURLQueryItem(name: String($0), value: String($1))
            }
        case .POST:
            queryString = components.percentEncodedQuery?.dataUsingEncoding(NSUTF8StringEncoding)
        default:
            break
        }
        
        let request = NSMutableURLRequest()
        request.HTTPMethod = task.method.rawValue
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        } else if let queryString = queryString {
            request.HTTPBody = queryString
        }
        
        guard let finalURL = components.URL else {
            return nil
        }
        
        request.URL = finalURL
        
        if task.authenticated, let token = token {
            var headers = task.headers
            headers["Authorization"] = "Bearer \(token)"
            request.allHTTPHeaderFields = headers
        }
        
        return request
    }
}
