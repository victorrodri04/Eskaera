//
//  HTTPSession.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation
import UIKit

class HTTPSession {
    
    static let sharedInstance = HTTPSession()
    var session : NSURLSession!
    private var internalAccessToken: String?
    
    var accessToken: String? {
        set {
            let configuration = session.configuration
            internalAccessToken = newValue
            var headers = configuration.HTTPAdditionalHeaders
            if newValue != nil {
                headers?.updateValue("Bearer \(newValue!)", forKey: "Authorization")
            } else {
                headers?.removeValueForKey("Authorization")
            }
            configuration.HTTPAdditionalHeaders = headers
            session = NSURLSession(configuration: configuration)
        }
        get {
            return internalAccessToken
        }
    }
    
    lazy var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    private init() {
        configureHeaders()
        configureCache()
        session = NSURLSession(configuration: sessionConfig)
    }
    
    func configureHeaders() {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let devModel = UIDevice.currentDevice().model
        let devVersion = UIDevice.currentDevice().systemVersion
        let devScale = UIScreen.mainScreen().scale
        let locale = NSLocale.currentLocale().localeIdentifier
        let systemTimeZone = NSTimeZone.systemTimeZone().abbreviation
        
        let userAgent = "\(appName)/\(appVersion) (\(devModel); iOS \(devVersion); Scale/\(devScale)); Locale/\(locale)); SystemTimeZone/\(systemTimeZone))"
        
        var deviceId = ""
        if let currentDeviceId = currentDeviceId {
            deviceId = currentDeviceId
            sessionConfig.HTTPAdditionalHeaders = ["Accept":"application/json",
                                                   "User-Agent": userAgent,
                                                   "X-Ticketchat-DeviceId": "iOS/\(deviceId)"]
        } else {
            sessionConfig.HTTPAdditionalHeaders = ["Accept":"application/json", "User-Agent": userAgent]
        }
    }
    
//    private lazy var userDefaults: UserDefaultsManager = UserDefaultsManager()
    
    private var currentDeviceId : String? {
        return nil //userDefaults.deviceId
    }
    
    private func configureCache() {
        let cache = NSURLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: nil)
        sessionConfig.URLCache = cache
        sessionConfig.requestCachePolicy = .UseProtocolCachePolicy
    }
    
}
