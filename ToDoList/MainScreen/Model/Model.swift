//
//  Model.swift
//  ToDoList
//
//  Created by Denis Borovoi on 11/8/24.
//

import UIKit

protocol TaskProtocol {
    var itemName: String { get set }
    var description: String? { get set }
    var completed: Bool { get set }
}

struct Item: TaskProtocol {
    var itemName: String
    var description: String?
    var completed: Bool
}
    
    

