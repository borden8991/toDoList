//
//  AddNotePresenter.swift
//  ToDoList
//
//  Created by Denis Borovoi on 16.12.2024.
//

import Foundation

protocol AddNoteViewInputProtocol: AnyObject {
    func didCreateNote()
}

final class AddNotePresenter {
    
    // MARK: - Private properties
    
    weak private var view: AddNoteViewInputProtocol?
    private let coreDataStack = CoreDataStack()
    
    // MARK: - Init
    
    init(view: AddNoteViewInputProtocol) {
        self.view = view
    }
}

extension AddNotePresenter: AddNoteViewOutputProtocol {
    func didPressCreateNoteButton(noteName: String,
                                  noteDescription: String?) {
        let note = NoteViewModel(id: UUID(),
                        noteName: noteName,
                        description: noteDescription,
                        completed: false)
        self.coreDataStack.createNote(note)
        self.view?.didCreateNote()
    }
}
