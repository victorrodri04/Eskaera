//
//  HTTPRequestQueue.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public class HTTPRequestQueue: TasksQueueProtocol {
    
    private var httpClient: HTTPClient
    private var tasksQueue = [Task]()
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func addTask(task: Task) {
        tasksQueue.append(task)
    }
    
    public func executeTasks() {
        
        if tasksQueue.count > 0 {
            let task = tasksQueue.removeFirst()
            httpClient.request(task) { [weak self] response in
                
                guard let `self` = self else { return }
                switch response {
                case .Success(_):
                    break
                case .Failure(_):
                    self.addTask(task)
                    break
                }
                
                task.completed(withResponse: response)
                
                self.executeTasks()
            }
        }
    }
}
