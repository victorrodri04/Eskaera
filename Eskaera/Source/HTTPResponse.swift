//
//  HTTPResponse.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public enum HTTPResponse {
    case Success(AnyObject?)
    case Failure(HTTPResponse.Error)
}

public extension HTTPResponse {
    
    enum Error: ErrorType {
        case SystemError
        case CouldNotDecodeJSON
        case CouldNotGetResponse
        case BadStatus(status: Int)
        case Other(NSError?)
    }
}
