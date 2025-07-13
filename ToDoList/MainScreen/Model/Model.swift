//
//  Model.swift
//  ToDoList
//
//  Created by Denis Borovoi on 11/8/24.
//

import UIKit

struct NoteViewModel {
    var id: UUID
    var noteName: String
    var description: String?
    var completed: Bool
    
    init(entity: NoteEntity) {
        self.id = entity.id ?? UUID()
        self.noteName = entity.noteName
        self.description = entity.noteDescription
        self.completed = entity.noteCompleted
    }
    
    init(id: UUID, noteName: String, description: String? = nil, completed: Bool) {
        self.id = id
        self.noteName = noteName
        self.description = description
        self.completed = completed
    }
}
    
extension NoteEntity {
    func update(from model: NoteViewModel) {
        self.id = model.id
        self.noteName = model.noteName
        self.noteDescription = model.description
        self.noteCompleted = model.completed
    }
}
