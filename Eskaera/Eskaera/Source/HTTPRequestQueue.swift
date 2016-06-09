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
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func addTask(task: Task) {
        tasksQueue.append(task)
    }
    
    func executeTasks() {
        guard let task = tasksQueue.first else { return }
        httpClient.request(task) { response in
            
            if let error = response.error {
                task.completed(withError: error)
            } else if let data = response.data {
                task.completed(withResponseData: data)
            }
        }
    }
}
