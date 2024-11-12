//
//  Model.swift
//  ToDoList
//
//  Created by user270963 on 11/8/24.
//

import UIKit

protocol TaskProtocol {
    var string: String { get set }
    var description: String? { get set }
   var completed: Bool { get set }
}

class Item: TaskProtocol {
    
    var string: String
    var description: String?
    var completed: Bool
    
    init(string: String, descriprion: String?, completed: Bool) {
        self.string = string
        self.description = descriprion
        self.completed = completed
    }
}

class Model {
    
    //MARK: -Var
    
    var editButtonClicked: Bool = false
    
    var toDoItems: [Item] = []
    
    var sortedAscending: Bool = true
    
    //MARK: -Methods
    
 
    func addItem(itemName: String, itemDescription: String, isCompleted: Bool = false) {
        toDoItems.append(Item(string: itemName, descriprion: itemDescription, completed: isCompleted))
    }
    
    func removeItem(at index: Int) {
        toDoItems.remove(at: index)
    }
    
    func moveItem(fromIndex: Int, toIndex: Int) {
        let from = toDoItems[fromIndex]
        toDoItems.remove(at: fromIndex)
        toDoItems.insert(from, at: toIndex)
    }
    
    func updateItem(at index: Int, with string: String, with description: String) {
        toDoItems[index].string = string
        toDoItems[index].description = description
    }
    
    func changeState(at item: Int) -> Bool {
        toDoItems[item].completed = toDoItems[item].completed
        return toDoItems[item].completed
    }
    
    func sortByTitle() {
        toDoItems.sort {
            sortedAscending ? $0.string < $1.string : $0.string > $1.string
        }
    }
        
    func search() {
            
    }
}
    
    

