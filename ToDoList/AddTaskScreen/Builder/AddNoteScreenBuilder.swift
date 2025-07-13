//
//  AddNoteScreenBuilder.swift
//  ToDoList
//
//  Created by Denis Borovoi on 12.12.2024.
//

import UIKit

final class AddNoteScreenBuilder {
    class func createAddNoteScreen() -> UIViewController {
        let view = NoteViewController()
        let presenter = AddNotePresenter(view: view)
        view.presenter = presenter
        print("created addnote screen")
        return view
    }
}
