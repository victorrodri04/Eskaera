//
//  FileManager.swift
//  Eskaera
//
//  Created by Victor Rodriguez Reche on 21/06/16.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

struct FileManager {
    
    static func fileExists(atPath path: String) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path)
    }
    
    static func path(withFileName filename: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docuemntsPath = path[0]
        return docuemntsPath.stringByAppendingString("/"+filename)
    }
    
    static func saveFile(withURL url: NSURL, atPath path: String) {
        
        guard let path = url.path else { return }
        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtPath(path)
            try fileManager.moveItemAtPath(path, toPath: path)
        } catch {
            
        }
    }
    
    static func data(fromFilePath filePath: String) -> AnyObject? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath)
    }
    
    static func save(data data: NSData, path: String) -> Bool {
        return data.writeToFile(path, atomically: true)
    }
}