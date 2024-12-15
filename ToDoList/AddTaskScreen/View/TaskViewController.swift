//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Vasily Maslov on 09.12.2024.
//

import UIKit

final class TaskViewController: UIViewController {

//MARK: - Private Properties

    private var navBar: UINavigationController?

    private var model = Model()

    private var doAfterEdit: ((Item) -> Void)?

    private var nameTaskField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter task..."
        text.backgroundColor = .white
        text.borderStyle = .roundedRect
        text.textAlignment = .left
        return text
    }()

    private var descriptionTaskField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter description..."
        text.backgroundColor = .white
        text.borderStyle = .roundedRect
        text.textAlignment = .left
        return text
    }()

    private var createTaskButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create task", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 0.5
        button.addTarget(self, action: #selector(buttonTask(sender: )), for: .touchUpInside)
        return button
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        createNameTextField()
        createDescriprionTextField()
        createTaskButtonConstreint()

        /* let appereance = UINavigationBarAppearance()
         self.navBar?.navigationBar.isTranslucent = false
         self.navBar?.navigationBar.barTintColor = .white
         appereance.backgroundColor = .white
         view.backgroundColor = .cyan*/

        self.title = "Add task"
        view.backgroundColor = .systemGray
    }

    //MARK: - Private Methods
    private func createNameTextField() {
        view.addSubview(nameTaskField)
        self.nameTaskField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.nameTaskField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.nameTaskField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.nameTaskField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110 ),
            self.nameTaskField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func createDescriprionTextField() {
        view.addSubview(descriptionTaskField)
        self.descriptionTaskField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.descriptionTaskField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.descriptionTaskField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.descriptionTaskField.topAnchor.constraint(equalTo: self.nameTaskField.bottomAnchor, constant: 20 ),
            self.descriptionTaskField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func createTaskButtonConstreint() {
        view.addSubview(createTaskButton)
        createTaskButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            createTaskButton.widthAnchor.constraint(equalToConstant: 150),
            createTaskButton.heightAnchor.constraint(equalToConstant: 60),
            createTaskButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            createTaskButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc func buttonTask(sender: Any) {
        print("Button is pressed")
        guard let unwrTextFieldValue = self.nameTaskField.text,
              let unweTextDescription = self.descriptionTaskField.text else { return }

        self.model.addItem(itemName: unwrTextFieldValue,
                           itemDescription: unweTextDescription)
        self.model.sortByTitle()
        navigationController?.popToRootViewController(animated: true)
        if nameTaskField.hasText == false {
            createTaskButton.isEnabled = false
        } else {
            createTaskButton.isEnabled = true
        }
    } // Вопрос

}


