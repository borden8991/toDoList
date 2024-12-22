//
//  AddTaskPresenter.swift
//  ToDoList
//
//  Created by Denis Borovoi on 16.12.2024.
//

import Foundation

protocol AddTaskViewInputProtocol: AnyObject {
    func didCreateTask()
}

final class AddTaskPresenter {
    
    // MARK: - Private properties
    
    weak private var view: AddTaskViewInputProtocol?
    
    private let coreDataStack = CoreDataStack()
    
    // MARK: - Init
    
    init(view: AddTaskViewInputProtocol) {
        self.view = view
    }
}

extension AddTaskPresenter: AddTaskViewOutputProtocol {
    func didPressCreateTaskButton(itemName: String, itemDescription: String?) {
        let item = Item(itemName: itemName,
                        description: itemDescription,
                        completed: false)
        self.coreDataStack.createItem(item)
        self.view?.didCreateTask()
    }
}
