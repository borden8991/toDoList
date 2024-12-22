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

    private func removeItem(index: Int) {
        let item = self.toDoItems[index]
        self.coreDataStack.deleteItem(item)
        self.toDoItems = self.coreDataStack.fetch()
    }

    private func moveItem(fromIndex: Int, toIndex: Int) {
        let from = toDoItems[fromIndex]
        toDoItems.remove(at: fromIndex)
        toDoItems.insert(from, at: toIndex)
        self.toDoItems = self.coreDataStack.fetch()
    }
    
    private func changeState(index: Int) -> Bool {
        toDoItems[index].completed = toDoItems[index].completed
        self.coreDataStack.createCheckmark(newCheckmark: true)
        self.toDoItems = self.coreDataStack.fetch()
        return toDoItems[index].completed
    }
    
    private func sortByTitle() {
        toDoItems.sort {
            sortedAscending ? $0.itemName < $1.itemName : $0.itemName > $1.itemName
        }
    }
        
    private func search() {
        
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


