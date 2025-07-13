//
//  MainViewOutput.swift
//  ToDoList
//
//  Created by Denis Borovoi on 22.12.2024.
//

import Foundation

protocol MainViewOutputProtocol: AnyObject {
    
    /// Кнопка изменения нажата.
    func editButtonClicked()

    /// Кнопка сортировки нажата.
    func sortByTitleButtonClicked()
    
    /// Вьюха была загружена.
    func viewDidLoad()
    
    /// Вьюха появилась.
    func viewDidAppear()
    
    /// Кнопка удаления нажата.
    /// - Parameter id: Идентификатор задачи, помеченной на удаление.
    func removeNoteButtonClicked(id: UUID)
    
    /// Кнопка изменения/обновления задачи нажата.
    /// - Parameters:
    ///   - id: ID задачи
    ///   - newName: Новое название задачи.
    ///   - newDescription: Новое описание задачи.
    func updateNoteButtonClicked(id: UUID, newName: String, newDescription: String?)
    
    /// Кнопка "Done" нажата
    /// - Parameter id: ID задачи.
    func toggleCompletion(at id: UUID)
    
    /// Текст в серч баре был изменен.
    /// - Parameter text: Набранный текст в поисковой строке.
    func searchbarTextDidChange(_ text: String)
}
