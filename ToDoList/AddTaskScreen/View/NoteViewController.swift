//
//  NoteViewController.swift
//  ToDoList
//
//  Created by Denis Borovoi on 09.12.2024.
//

import UIKit

final class NoteViewController: UIViewController {

    //MARK: - Private Properties
    
    private var navBar: UINavigationController?

    private var nameNoteField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter note..."
        text.backgroundColor = .white
        text.borderStyle = .roundedRect
        text.textAlignment = .left
        return text
    }()

    private var descriptionNoteTextView: UITextView = {
        let text = UITextView()
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.layer.borderWidth = 0.5
        text.layer.cornerRadius = 4
        text.font = UIFont.systemFont(ofSize: 17)
        text.textColor = .lightGray
        return text
    }()

    private var createNoteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create note", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonNote(sender: )), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    //MARK: - Properties
    
    var presenter: AddNoteViewOutputProtocol?

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        createNameTextField()
        createDescriprionTextField()
        createNoteButtonConstraint()

        self.title = "Add note"
        self.view.backgroundColor = .white
    }

    //MARK: - Private Methods
    
    private func createNameTextField() {
        view.addSubview(nameNoteField)
        self.nameNoteField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        self.nameNoteField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.nameNoteField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.nameNoteField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.nameNoteField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 110 ),
            self.nameNoteField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc
    func textFieldDidChange(_ textField: UITextField) {
        createNoteButton.isEnabled = textField.hasText
    }
    
    private func createDescriprionTextField() {
        view.addSubview(descriptionNoteTextView)
        self.descriptionNoteTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.descriptionNoteTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.descriptionNoteTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.descriptionNoteTextView.topAnchor.constraint(equalTo: self.nameNoteField.bottomAnchor, constant: 10 ),
            self.descriptionNoteTextView.heightAnchor.constraint(equalToConstant: 50)
        ])
        func textViewShouldReturn(_ textView: UITextView) -> Bool {
            textView.resignFirstResponder()  // Прячем клавиатуру при нажатии "Ввод"
            return true
        }
    }

    private func createNoteButtonConstraint() {
        view.addSubview(createNoteButton)
        self.createNoteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.createNoteButton.widthAnchor.constraint(equalToConstant: 150),
            self.createNoteButton.heightAnchor.constraint(equalToConstant: 60),
            self.createNoteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.createNoteButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }

    @objc
    func buttonNote(sender: Any) {
        print("Button is pressed")
        guard let title = self.nameNoteField.text else { return }
        self.presenter?.didPressCreateNoteButton(noteName: title,
                                                 noteDescription: self.descriptionNoteTextView.text)
    }
}

// MARK: - AddNoteViewInputProtocol

extension NoteViewController: AddNoteViewInputProtocol {
    func didCreateNote() {
        navigationController?.popToRootViewController(animated: true)
    }
}



