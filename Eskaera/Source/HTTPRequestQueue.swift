//
//  HTTPRequestQueue.swift
//  Eskaera
//
//  Created by Victor on 08/06/2016.
//  Copyright © 2016 Victor Rodriguez Reche. All rights reserved.
//

import Foundation

open class Request: NSObject, NSCoding {
    
    var task: Task?
    var taskDictionary: JSON?
    
    convenience init(task: Task) {
        self.init()
        self.task = task
    }
    
    @objc public required convenience init(coder decoder: NSCoder) {
        self.init()
        self.taskDictionary = decoder.decodeObject(forKey: "taskDictionary") as? JSON
    }
    
    @objc open func encode(with coder: NSCoder) {
        let dictionary = task?.json ?? taskDictionary
        coder.encode(dictionary, forKey: "taskDictionary")
    }
}

open class HTTPRequestQueue: TasksQueueProtocol {
    
    open static let sharedInstance = HTTPRequestQueue(httpClient: HTTPClient.sharedInstance)
    
    fileprivate typealias Queue = [Request]
    fileprivate let queueKey = "persistentQueue"
    
    open var httpClient: HTTPClient
    
    fileprivate lazy var pendingQueue: Queue = {
        return self.getQueue()
    }()
    
    fileprivate var inProgressRequests = [String: Request]()
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    open func addTask(_ task: Task) {
        if task.persist {
            persistTask(task)
        }
        let request = Request(task: task)
        return appendRequest(request)
    }
    
    fileprivate func persistTask(_ task: Task) {
        let request = Request(task: task)
        saveRequest(request)
    }
    
    open func executeTask(_ task: Task) {
        addTask(task)
        executeTasks()
    }
    
    open func executeTasks() {
        executeTasks(withQueue: pendingQueue)
    }
    
    fileprivate func appendRequest(_ request: Request) {
        let append = !requestsQueue(pendingQueue, containsRequest: request)
        if append {
            pendingQueue.append(request)
        }
    }
    
    fileprivate func requestsQueue(_ queue: Queue, containsRequest request: Request) -> Bool {
        return queue.contains {
            if let newQueueTask = $0.task, let requestTask = request.task {
                return newQueueTask.identifier == requestTask.identifier
            } else if let newQueueTaskToken = $0.taskDictionary?[TaskConstants.identifier.rawValue] as? String,
                let requestTaskToken = request.taskDictionary?[TaskConstants.identifier.rawValue] as? String {
                return newQueueTaskToken == requestTaskToken
            } else {
                return false
            }
        }
    }
    
    fileprivate func executeTasks(withQueue queue: Queue) {
        
        if queue.count < 1 { return }
        
        var tasksQueue = Queue()
        tasksQueue.append(contentsOf: queue)
        var tasksQueueCopy = Queue()
        tasksQueueCopy.append(contentsOf: queue)
        var nextRequest: Request?
        
        for request in tasksQueueCopy {
            if let identifier = request.task?.identifier ?? request.taskDictionary?[TaskConstants.identifier.rawValue] as? String,
                inProgressRequests[identifier] == nil {
                nextRequest = request
                if let index = tasksQueue.index(of: request) {
                    tasksQueue.remove(at: index)
                }
                break
            } else {
                if let index = tasksQueue.index(of: request) {
                    tasksQueue.remove(at: index)
                }
            }
        }
        
        guard
            let request = nextRequest,
            let token = request.task?.identifier ?? request.taskDictionary?[TaskConstants.identifier.rawValue] as? String
        else {
            return
        }
        
        inProgressRequests[token] = request
        
        httpClient.request(request) { response in
            
            self.inProgressRequests.removeValue(forKey: token)
            var overridePersistedQueue = false
            switch response {
            case .success(_):
                overridePersistedQueue = true
                break
            case .failure(let error):
                if case .resquest(let data) = error, let task = request.task as? ErrorSkipable {
                    guard let data = data else { break }
                    // If the task should be persisted do not override the persisted queue to not loose the task
                    if task.shoulPersistTask(with: data) {
                        overridePersistedQueue = false
                    }
                }
            }
            
            if overridePersistedQueue {
                let _ = self.persist(queue: tasksQueue)
            }
            
            request.task?.completed(with: response)
            self.executeTasks(withQueue: tasksQueue)
        }
    }
    
    fileprivate func getQueue() -> Queue {
        let filePath = FileManager.path(withFileName: queueKey)
        guard let data = FileManager.data(fromFilePath: filePath),
            let queue = data as? Queue else {
                return Queue()
        }
        return queue
    }
    
    fileprivate func saveRequest(_ request: Request) {
        
        var newQueue = pendingQueue
        var dictionary:JSON?
        
        if let task = request.task {
            dictionary = task.json
        } else if let taskDictionary = request.taskDictionary,
            let persist = taskDictionary[TaskConstants.persist.rawValue] as? Bool , persist {
            dictionary = taskDictionary
        }
        
        guard
            let taskDictionary = dictionary,
            let identifier = taskDictionary[TaskConstants.identifier.rawValue] as? String
        else {
            return
        }
        
        if !newQueue.contains { $0.task?.identifier == identifier } {
            newQueue.append(request)
            pendingQueue = persist(queue: newQueue) ? newQueue : pendingQueue
        }
    }
    
    fileprivate func persist(queue: Queue) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: queue)
        return FileManager.save(data: data, path: FileManager.path(withFileName: queueKey))
    }
}
