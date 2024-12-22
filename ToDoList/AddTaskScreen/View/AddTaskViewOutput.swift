//
//  AddTaskViewOutput.swift
//  ToDoList
//
//  Created by Denis Borovoi on 22.12.2024.
//

import Foundation

protocol AddTaskViewOutputProtocol: AnyObject {
    
    /// Нажата кнопка создания задачи
    /// - Parameters:
    ///   - itemName: Имя задачи
    ///   - itemDescription: Описание задачи
    func didPressCreateTaskButton(itemName: String, itemDescription: String?)
}
