//
//  TaskViewController.swift
//  ToDoList
//
//  Created by Denis Borovoi on 09.12.2024.
//

import UIKit

final class TaskViewController: UIViewController {

//MARK: - Private Properties

    private var navBar: UINavigationController?
    
    var presenter: AddTaskViewOutputProtocol?

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
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonTask(sender: )), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        createNameTextField()
        createDescriprionTextField()
        createTaskButtonConstreint()

        self.title = "Add task"
        self.view.backgroundColor = .white
    }

    //MARK: - Private Methods
    
    private func createNameTextField() {
        view.addSubview(nameTaskField)
        self.nameTaskField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        self.nameTaskField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.nameTaskField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.nameTaskField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.nameTaskField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110 ),
            self.nameTaskField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        createTaskButton.isEnabled = textField.hasText
    }
    
    func createDescriprionTextField() {
        view.addSubview(descriptionTaskField)
        self.descriptionTaskField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.descriptionTaskField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.descriptionTaskField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.descriptionTaskField.topAnchor.constraint(equalTo: self.nameTaskField.bottomAnchor, constant: 10 ),
            self.descriptionTaskField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func createTaskButtonConstreint() {
        view.addSubview(createTaskButton)
        self.createTaskButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.createTaskButton.widthAnchor.constraint(equalToConstant: 150),
            self.createTaskButton.heightAnchor.constraint(equalToConstant: 60),
            self.createTaskButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.createTaskButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc func buttonTask(sender: Any) {
        print("Button is pressed")
        guard let title = self.nameTaskField.text else { return }
        
        self.presenter?.didPressCreateTaskButton(itemName: title, itemDescription: self.descriptionTaskField.text)
    }
}

// MARK: - AddTaskViewInputProtocol

extension TaskViewController: AddTaskViewInputProtocol {
    func didCreateTask() {
        navigationController?.popToRootViewController(animated: true)
    }
}



