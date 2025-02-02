//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Denis Borovoi on 16.12.2024.
//

import Foundation

protocol MainViewInputProtocol: AnyObject {
    
    /// Обновить экран с сохраненными задачами.
    /// - Parameter items: Массив задач.
    func updateScreen(with items: [Item])
    
    func failure(error: Error)
}

class MainPresenter {
    private var isFirstAppear = true
    private let coreDataStack = CoreDataStack()
    private var toDoItems: [Item] = []
    var editButtonClicked: Bool = false
    var sortedAscending: Bool = true
    weak private var view: MainViewInputProtocol?
    init(view: MainViewInputProtocol) {
        self.view = view
    }
}

// MARK: - Private methods

extension MainPresenter {

    private func fetchItems() {
        self.toDoItems = self.coreDataStack.fetch()
    }

    func removeItem(index: Int) {
        let item = self.toDoItems[index]
        self.coreDataStack.deleteItem(item)
        self.toDoItems = self.coreDataStack.fetch()
        self.view?.updateScreen(with: self.toDoItems)
    }
    
    func updateItem(newName: String, newDescription: String?) {
        //item.itemName = newName
        let item = Item(itemName: newName, description: newDescription, completed: false)
        self.coreDataStack.updateItem(item: item, newName: newName, newDescription: newDescription ?? "")
        self.toDoItems = self.coreDataStack.fetch()
        self.view?.updateScreen(with: self.toDoItems)
    }

    private func moveItem(fromIndex: Int, toIndex: Int) {
        let from = toDoItems[fromIndex]
        toDoItems.remove(at: fromIndex)
        toDoItems.insert(from, at: toIndex)
        self.toDoItems = self.coreDataStack.fetch()
    }
    
    // не использовано пока
    private func changeState(index: Int) -> Bool {
        toDoItems[index].completed = toDoItems[index].completed
        self.coreDataStack.createCheckmark(newCheckmark: true)
        self.toDoItems = self.coreDataStack.fetch()
        self.view?.updateScreen(with: self.toDoItems)
        return toDoItems[index].completed
    }
    
    func sortByTitle() {
        self.toDoItems.sort { sortedAscending ? $0.itemName < $1.itemName : $0.itemName > $1.itemName }
        self.view?.updateScreen(with: self.toDoItems)
    }
}

extension MainPresenter: MainViewOutputProtocol {
    func viewDidLoad() {
        self.fetchItems()
        self.view?.updateScreen(with: self.toDoItems)
    }
    
    func viewDidAppear() {
        if !self.isFirstAppear {
            self.fetchItems()
            self.view?.updateScreen(with: self.toDoItems)
        }
        self.isFirstAppear = false
    }
}


