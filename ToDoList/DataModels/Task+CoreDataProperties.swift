//
//  Task+CoreDataProperties.swift
//  ToDoList
//
//  Created by Vasily Maslov on 24.11.2024.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var itemCompleted: Bool
    @NSManaged public var itemDescription: String?
    @NSManaged public var itemName: String

}

extension Task : Identifiable {

}
