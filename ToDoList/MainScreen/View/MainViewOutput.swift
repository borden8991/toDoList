//
//  MainViewOutput.swift
//  ToDoList
//
//  Created by Denis Borovoi on 22.12.2024.
//

import Foundation

protocol MainViewOutputProtocol: AnyObject {
    var sortedAscending: Bool { get set }
    var editButtonClicked: Bool { get set }
    func viewDidLoad()
    func viewDidAppear()
    func sortByTitle()
    func removeItem(index: Int)
    func updateItem(newName: String, newDescription: String?)
}
