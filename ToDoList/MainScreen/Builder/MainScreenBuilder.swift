//
//  MainScreenBuilder.swift
//  ToDoList
//
//  Created by Denis Borovoi on 12.12.2024.
//

import UIKit

final class MainScreenBuilder {
    class func createMainScreen() -> UIViewController {
        let view = ViewController()
        let presenter = MainPresenter(view: view)
        view.presenter = presenter
        print("created main screen")
        return view
    }
}
