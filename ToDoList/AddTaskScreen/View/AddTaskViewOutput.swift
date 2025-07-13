//
//  AddNoteViewOutput.swift
//  ToDoList
//
//  Created by Denis Borovoi on 22.12.2024.
//

import Foundation

protocol AddNoteViewOutputProtocol: AnyObject {
    
    /// Нажата кнопка создания задачи
    /// - Parameters:
    ///   - noteName: Имя задачи
    ///   - noteDescription: Описание задачи
    func didPressCreateNoteButton(noteName: String, noteDescription: String?)
}
