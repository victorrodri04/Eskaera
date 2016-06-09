//
//  HTTPResponse.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public enum HTTPResponse {
    case Success(NSData)
    case Failure(HTTPResponse.Error?)
}

public extension HTTPResponse {
    var data: NSData? {
        switch self {
        case .Success(let data):
            return data
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .Success(_):
            return nil
        case .Failure(let error):
            return error
        }
    }
    
    enum Error: ErrorType {
        case CouldNotDecodeJSON
        case CouldNotGetResponse
        case BadStatus(status: Int)
        case Other(NSError?)
    }
}
