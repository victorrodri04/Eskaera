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
        return Foundation.FileManager.default.fileExists(atPath: path)
    }
    
    static func path(withFileName filename: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docuemntsPath = path[0]
        return docuemntsPath + ("/"+filename)
    }
    
    static func data(fromFilePath filePath: String) -> AnyObject? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as AnyObject?
    }
    
    static func save(data: Data, path: String) -> Bool {
        return ((try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil)
    }
}
