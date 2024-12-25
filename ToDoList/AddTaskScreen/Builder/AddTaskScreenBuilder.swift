//
//  AddTaskScreenBuilder.swift
//  ToDoList
//
//  Created by Denis Borovoi on 12.12.2024.
//

import UIKit

final class AddTaskScreenBuilder {
    class func createAddTaskScreen() -> UIViewController {
        let view = TaskViewController()
        let presenter = AddTaskPresenter(view: view)
        view.presenter = presenter
        print("created addtask screen")
        return view
    }
}
