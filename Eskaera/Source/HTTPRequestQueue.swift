//
//  HTTPRequestQueue.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

private class Request {
    let task: Task
    
    init(task: Task) {
        self.task = task
    }
}

public class HTTPRequestQueue: TasksQueueProtocol {
    
    private typealias Queue = [Request]
    private let queueKey = "persistentQueue"
    
    private var httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func executeTask(task: Task) {
        let request = Request(task: task)
        persistRequest(request)
        let pendingQueue = getQueue()
        let queue = appendRequest(request, queue: pendingQueue)
        executeTasks(withQueue: queue)
    }
    
    private func appendRequest(request: Request, queue: Queue) -> Queue {
        var newQueue = queue
        let append = !newQueue.contains{ $0.task.token == request.task.token }
        if append {
            newQueue.append(request)
        }
        return newQueue
    }
    
    private func executeTasks(withQueue queue: Queue) {
        var tasksQueue = queue
        if tasksQueue.count > 0 {
            let request = tasksQueue.removeFirst()
            httpClient.request(request.task) { [weak self] response in
                
                guard let `self` = self else { return }
                
                switch response {
                case .Success(_):
                    break
                case .Failure(_):
                    if request.task.persist { self.persistRequest(request) }
                    break
                }
                
                request.task.completed(withResponse: response)
                
                self.executeTasks(withQueue: tasksQueue)
            }
        }
    }
    
    private func persistRequest(request: Request) {
        var queue = getQueue()
        let append = !queue.contains{ $0.task.token == request.task.token }
        if append {
            queue.append(request)
            saveQueue(queue)
        }
    }
    
    private func nextTask() -> Request? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard var queue = userDefaults.objectForKey(queueKey) as? Queue else {
            return nil
        }
        let request = queue.removeFirst()
        saveQueue(queue)
        return request
    }
    
    private func getQueue() -> Queue {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        guard let queue = userDefaults.objectForKey(queueKey) as? Queue else {
            return Queue()
        }
        return queue
    }
    
    private func saveQueue(queue: Queue) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(queue, forKey: queueKey)
        userDefaults.synchronize()
    }
}
