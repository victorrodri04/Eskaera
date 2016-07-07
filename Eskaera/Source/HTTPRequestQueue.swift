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
        let dictionary = task?.json ?? taskDictionary
        coder.encodeObject(dictionary, forKey: "taskDictionary")
    }
}

public class HTTPRequestQueue: TasksQueueProtocol {
    
    public static let sharedInstance = HTTPRequestQueue(httpClient: HTTPClient.sharedInstance)
    
    private typealias Queue = [Request]
    private let queueKey = "persistentQueue"
    
    public var httpClient: HTTPClient
    
    private var pendingQueue: Queue {
        return getQueue()
    }
    
    private var inProgressRequests = [String: Request]()
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public func addTask(task: Task) {
        let request = Request(task: task)
        var queue: Queue!
        if task.persist {
            guard let savedQueue = persistRequest(request, inQueue: pendingQueue) else {
                request.task?.completed(withResponse: HTTPResponse.Failure(HTTPResponse.Error.SystemError))
                return
            }
            queue = savedQueue
        } else {
            queue = appendRequest(request, queue: pendingQueue)
        }
    }
    
    public func executeTask(task: Task) {
        addTask(task)
        executeTasks()
    }
    
    public func executeTasks() {
        executeTasks(withQueue: pendingQueue)
    }
    
    private func persistRequest(request: Request, inQueue queue: Queue) -> Queue? {
        guard let savedQueue = saveRequest(request, withQueue: queue) else {
            return nil
        }
        return savedQueue
    }
    
    private func appendRequest(request: Request, queue: Queue) -> Queue {
        var newQueue = queue
        let append = !requestsQueue(queue, containsRequest: request)
        if append {
            newQueue.append(request)
        }
        return newQueue
    }
    
    private func requestsQueue(queue: Queue, containsRequest request: Request) -> Bool {
        return queue.contains {
            if let newQueueTask = $0.task, requestTask = request.task {
                return newQueueTask.token == requestTask.token
            } else if let newQueueTaskToken = $0.taskDictionary?[TaskConstants.token.rawValue] as? String,
                requestTaskToken = request.taskDictionary?[TaskConstants.token.rawValue] as? String {
                return newQueueTaskToken == requestTaskToken
            } else {
                return false
            }
        }
    }
    
    private func executeTasks(withQueue queue: Queue) {
        
        var tasksQueue = queue
        
        if tasksQueue.count > 0{
            
            let request = tasksQueue.removeFirst()
            
            guard let token = request.task?.token ?? request.taskDictionary?[TaskConstants.token.rawValue] as? String
                where inProgressRequests[token] == nil  else { return }
                
            inProgressRequests[token] = request
            
            httpClient.request(request) { [weak self] response in
                
                guard let `self` = self else { return }
                
                self.inProgressRequests.removeValueForKey(token)
                
                switch response {
                case .Success(_):
                    break
                case .Failure(_):
                    self.persist(queue: tasksQueue)
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
        
        if let task = request.task {
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
