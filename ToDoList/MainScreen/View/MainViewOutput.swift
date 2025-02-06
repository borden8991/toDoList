//
//  MainViewOutput.swift
//  ToDoList
//
//  Created by Denis Borovoi on 22.12.2024.
//

import Foundation

protocol MainViewOutputProtocol: AnyObject {
    /// Кнопка изменения нажата
    func editButtonClicked()

    /// Кнопка сортировки нажата
    func sortByTitleButtonClicked()
    
    /// Вьюха была загружена
    func viewDidLoad()
    
    /// <#Description#>
    func viewDidAppear()
    
    /// Кнопка удаления нажата.
    /// - Parameter index: Строка с задачей
    func removeItemButtonClicked(index: Int)
    
    /// Кнопка изменения/обновления задачи нажата.
    /// - Parameters:
    ///   - newName: Новое название задачи.
    ///   - newDescription: Новое описание задачи.
    func updateItemButtonClicked(newName: String, newDescription: String?)
}
