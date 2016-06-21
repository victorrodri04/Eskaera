//
//  HTTPRequestQueue.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

public class Request: NSObject, NSCoding {
    
    var task: Task?
    var taskDictionary: JSON?
    
    convenience init(task: Task) {
        self.init()
        self.task = task
    }
    
    @objc public required convenience init(coder decoder: NSCoder) {
        self.init()
        self.taskDictionary = decoder.decodeObjectForKey("taskDictionary") as? JSON
    }
    
    @objc public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(taskDictionary, forKey: "taskDictionary")
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
        let pendingQueue = getQueue()
        
        var queue: Queue!
        if task.persist {
            guard let savedQueue = saveRequest(request, withQueue: pendingQueue) else {
                return task.completed(withResponse: HTTPResponse.Failure(HTTPResponse.Error.SystemError))
            }
            queue = savedQueue
        } else {
            queue = appendRequest(request, queue: pendingQueue)
        }
        
        executeTasks(withQueue: queue)
    }
    
    private func appendRequest(request: Request, queue: Queue) -> Queue {
        var newQueue = queue
        //        var persist = false
        
        let append = !newQueue.contains{
            if let newQueueTask = $0.task, requestTask = request.task {
                return newQueueTask.token == requestTask.token
            } else if let newQueueTaskToken = $0.taskDictionary?[TaskConstants.token.rawValue] as? String,
                requestTaskToken = request.taskDictionary?[TaskConstants.token.rawValue] as? String {
                return newQueueTaskToken == requestTaskToken
            } else {
                return false
            }
        }
        
        if append {
            newQueue.append(request)
        }
        return newQueue
    }
    
    private func executeTasks(withQueue queue: Queue) {
        var tasksQueue = queue
        if tasksQueue.count > 0 {
            print("\(tasksQueue.count)")
            let request = tasksQueue.removeFirst()
            
            httpClient.request(request) { [weak self] response in
                
                guard let `self` = self else { return }
                
                switch response {
                case .Success(_):
                    self.persist(queue: tasksQueue)
                    break
                case .Failure(_):
                    break
                }
                
                request.task?.completed(withResponse: response)
                self.executeTasks(withQueue: tasksQueue)
            }
        }
    }
    
    private func getQueue() -> Queue {
        let filePath = FileManager.path(withFileName: queueKey)
        guard let data = FileManager.data(fromFilePath: filePath),
            queue = data as? Queue else {
                return Queue()
        }
        return queue
    }
    
    private func saveRequest(request: Request, withQueue queue: Queue) -> Queue? {
        
        var newQueue = queue
        var dictionary:JSON?
        
        if let task = request.task where task.persist {
            dictionary = task.json
        } else if let taskDictionary = request.taskDictionary,
            persist = taskDictionary[TaskConstants.persist.rawValue] as? Bool where persist {
            dictionary = taskDictionary
        }
        
        guard let taskDictionary = dictionary,
            let token = taskDictionary[TaskConstants.token.rawValue] as? String
            else { return nil }
        
        let append = !newQueue.contains{ $0.task?.token == token }
        
        if append {
            newQueue.append(request)
            return persist(queue: newQueue) ? newQueue : nil
        }
        
        return newQueue
    }
    
    private func persist(queue queue: Queue) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(queue)
        return FileManager.save(data: data, path: FileManager.path(withFileName: queueKey))
    }
}
