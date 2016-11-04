//
//  HTTPResponse.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public enum HTTPResponse {
    case success(Data?)
    case failure(HTTPResponse.error)
}

public extension HTTPResponse {
    
    enum error: Error {
        case system
        case couldNotDecodeJSON
        case couldNotGetResponse
        case resquest(data: Data?)
        case other(Error?)
    }
}
