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
    
    public init() { }
    
    public func request(task: Task, completion: HTTPResponse -> Void) {
        
        guard let request = request(withTask: task) else { return }
        
        let configuration = task.configuration
        
        var nsurlSession: NSURLSession?
        
        if let accessToken = task.authenticationToken {
            var headers = configuration.HTTPAdditionalHeaders
            headers?.updateValue("Bearer \(accessToken)", forKey: "Authorization")
            configuration.HTTPAdditionalHeaders = headers
        }
        nsurlSession = NSURLSession(configuration: configuration)
        
        guard let session = nsurlSession else {
            return completion(HTTPResponse.Failure(HTTPResponse.Error.CouldNotGetResponse))
        }
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            guard let httpResponse = response as? NSHTTPURLResponse else {
                completion(HTTPResponse.Failure(HTTPResponse.Error.CouldNotGetResponse))
                return
            }
            
            if 200 ..< 300 ~= httpResponse.statusCode {
                guard let data = data else {
                    let error = HTTPResponse.Error.Other(error)
                    completion(HTTPResponse.Failure(error))
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
        
        // NSURLComponents can fail due to programming errors, so
        // prefer crashing than returning an optional
        
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to create URL components from \(URL)")
        }
        
        components.queryItems = task.parameters.map {
            NSURLQueryItem(name: String($0), value: String($1))
        }
        
        guard let finalURL = components.URL else {
            fatalError("Unable to retrieve final URL")
        }
        
        let request = NSMutableURLRequest(URL: finalURL)
        request.HTTPMethod = task.method.rawValue
        
        return request
    }
}