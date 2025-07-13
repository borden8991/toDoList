//
//  NoteEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Denis Borovoi on 25.05.2025.
//
//

import Foundation
import CoreData


extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "NoteEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var noteName: String
    @NSManaged public var orderIndex: Int64
    @NSManaged public var noteCompleted: Bool
    @NSManaged public var noteDescription: String?

}

extension NoteEntity : Identifiable {

}
