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
    
    /// Обновить экран с состоянием изменения всех записей.
    /// - Parameter isEditing: Редактируется ли.
    func updateEditingState(isEditing: Bool)
    
    /// Обновить экран с измененным порядом задач.
    /// - Parameter isAscending: A-Z / Z-A
    func updateAscendingState(isAscending: Bool)
}

final class MainPresenter {
    
    // MARK: - Private properites
    
    private var isFirstAppear = true
    private let coreDataStack = CoreDataStack()
    private var toDoItems: [Item] = []
    private var isEditing: Bool = false
    private lazy var isAscending: Bool = self.savedOrder ?? false
    private var savedOrder: Bool? {
        false
        // логика чтения
        //добавить извлечение свойства сортировки из UserDefaults
    }
    weak private var view: MainViewInputProtocol?
    
    // MARK: - Init
    
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
        self.view?.updateScreen(with: self.toDoItems)
    }
    
    private func updateItem(newName: String, newDescription: String?) {
        let item = Item(itemName: newName, description: newDescription, completed: false)
        self.coreDataStack.updateItem(item: item, newName: newName, newDescription: newDescription ?? "")
        self.toDoItems = self.coreDataStack.fetch()
        self.view?.updateScreen(with: self.toDoItems)
    }

//    private func moveItem(fromIndex: Int, toIndex: Int) {
//        let from = toDoItems[fromIndex]
//        toDoItems.remove(at: fromIndex)
//        toDoItems.insert(from, at: toIndex)
//        self.toDoItems = self.coreDataStack.fetch()
//    }
    
    // не использовано пока
    private func changeState(index: Int) -> Bool {
        toDoItems[index].completed = toDoItems[index].completed
        self.coreDataStack.createCheckmark(newCheckmark: true)
        self.toDoItems = self.coreDataStack.fetch()
        self.view?.updateScreen(with: self.toDoItems)
        return toDoItems[index].completed
    }
}

extension MainPresenter: MainViewOutputProtocol {
    func editButtonClicked() {
        self.isEditing.toggle()
        self.view?.updateEditingState(isEditing: self.isEditing)
    }
    
    func sortByTitleButtonClicked() {
        let currentAscendingState = self.isAscending
        // Тут будет логика (записи) изменения свойства из ascending в userDefaults обратная currentAscendingState
        self.isAscending.toggle() // удалить после юзания userDefaults
        self.toDoItems.sort { self.isAscending ? $1.itemName < $0.itemName : $1.itemName > $0.itemName }
        self.view?.updateAscendingState(isAscending: self.isAscending)
        self.view?.updateScreen(with: self.toDoItems)
    }
    
    func removeItemButtonClicked(index: Int) {
        self.removeItem(index: index)
    }
    
    func updateItemButtonClicked(newName: String, newDescription: String?) {
        self.updateItem(newName: newName, newDescription: newDescription)
    }
    
    func didClickEditCellContent() {
        
    }
    
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


