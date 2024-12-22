//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Denis Borovoi on 24.11.2024.
//

import CoreData
import UIKit

class CoreDataStack {
    
    // MARK: - Public Properties
    
    static let shared = CoreDataStack()

    public let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    public var context: NSManagedObjectContext { persistentContainer.viewContext }

    // MARK: - Public Methods
    
    public func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }

    public func fetch(with searchText: String?,
                      isAscending: Bool) -> [NoteViewModel] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "noteName", ascending: isAscending)]
        if let searchText,
            !searchText.isEmpty {
            request.predicate = NSPredicate(format: "noteName CONTAINS[cd] %@", searchText)
        }
        
        let result = try? context.fetch(request)
        return result?.map { NoteViewModel(entity: $0) } ?? []
    }

    public func createNote(_ model: NoteViewModel) {
        self.context.performAndWait {
            let entity = NoteEntity(context: self.context)
            entity.update(from: model)
            saveContext()
        }
    }
    
    public func updateNote(id: UUID, title: String, description: String?) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try? context.fetch(request).first {
            entity.noteName = title
            if let description {
                entity.noteDescription = description
            }
            saveContext()
        }
    }

    public func deleteNote(_ id: UUID) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            saveContext()
        }
    }

    public func toggleNoteCompletion(_ id: UUID) {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try? context.fetch(request).first {
            entity.noteCompleted.toggle()
            saveContext()
        }
    }
}

