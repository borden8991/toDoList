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

    // MARK: - CoreData

    private let coreDataStack = CoreDataStack()

    //MARK: -Var
    
    var editButtonClicked: Bool = false
    
    /*var toDoItems: [Item] = [
                             Item(string: "Booba", descriprion: "Popa", completed: false),
                             Item(string: "SeaSya", descriprion: "Pisya", completed: false),
                             Item(string: "HGOHJGODPSHGOPSDHGPOHDSGPOHSDOPGHOPDSHGOPSDHGOPDSHGOPHSDOPGHSOPDGHPOSHDGPOHSDGPOHSPG", descriprion: "GPSLDMGOPDSOPGNDSOPGNPONGOPDSNGPONDSGPNSGP", completed: false)
                            ]*/

    var toDoItems: [Item] = []

    var sortedAscending: Bool = true

    init() {
        self.toDoItems = self.coreDataStack.fetch()
    }

    //MARK: - Methods

    func fetchItems() -> [Item] {
        self.toDoItems = self.coreDataStack.fetch()
        return self.toDoItems
    }
    
    func addItem(itemName: String, itemDescription: String, isCompleted: Bool = false) {
        let item = Item(string: itemName, descriprion: itemDescription, completed: isCompleted)
        self.coreDataStack.createItem(item)
        self.toDoItems = self.coreDataStack.fetch()
//        toDoItems.append(Item(string: itemName, descriprion: itemDescription, completed: isCompleted))
    }
   /* func removeItem(itemName: String, itemDescription: String, isCompleted: Bool = false) {
        //self.toDoItems.remove(at: )
        let item = Item(string: itemName, descriprion: itemDescription, completed: isCompleted)
        self.coreDataStack.deleteItem(item)
        self.toDoItems = self.coreDataStack.fetch()
    }*/

    func removeItem(itemName: String, itemDescription: String, isCompleted: Bool = false) {
        let item = Item(string: itemName, descriprion: itemDescription, completed: isCompleted)
        self.coreDataStack.deleteItem(with: item)
        self.toDoItems = self.coreDataStack.fetch()
    }

    func moveItem(fromIndex: Int, toIndex: Int) {
        let from = toDoItems[fromIndex]
        toDoItems.remove(at: fromIndex)
        toDoItems.insert(from, at: toIndex)
    }
    
    func updateItem(at index: Int, with string: String, with description: String) {
        toDoItems[index].string = string
        toDoItems[index].description = description
        self.coreDataStack.updateItem(toDoItems[index])
        self.toDoItems = self.coreDataStack.fetch()
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
    
    

