//
//  Storage.swift
//  ToDoList
//
//  Created by user270963 on 11/10/24.
//

import UIKit

protocol TaskStorageProtocol {
    func load() -> [TaskProtocol]
    func save(task: [TaskProtocol])
}

class TaskStorage: TaskStorageProtocol {

    private var storage = UserDefaults.standard
    
    private var storageKey = "tasks"
    
    private enum TaskKey: String {
        case itemName
        case itemDiscription
        //case completed
    }
 
    func load() -> [any TaskProtocol] {
        var resultTasks: [TaskProtocol] = []
        let taskFromStorage = storage.array(forKey: storageKey) as? [[String:String]] ?? []
        for task in taskFromStorage {
            guard let itemName = task[TaskKey.itemName.rawValue],
                  let itemDiscription = task[TaskKey.itemDiscription.rawValue]
            else {
                continue
            }
            resultTasks.append(Item(string: itemName, descriprion: itemDiscription, completed: true))
        }
        
        return resultTasks
    }
    
    func save(task: [any TaskProtocol]) {
        var arrayForStorage: [[String:String]] = []
        task.forEach { task in
            var newElementForStorage: Dictionary<String, String> = [:]
            newElementForStorage[TaskKey.itemName.rawValue] = task.string
            newElementForStorage[TaskKey.itemDiscription.rawValue] = task.description
            
            arrayForStorage.append(newElementForStorage)
        }
        storage.set(arrayForStorage, forKey: storageKey)
    }
    
}
