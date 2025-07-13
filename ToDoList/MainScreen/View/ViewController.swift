//
//  ViewController.swift
//  ToDoList
//
//  Created by Denis Borovoi on 11/8/24.
//

import UIKit
import CoreData

final class ViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let arrowUpImage = UIImage(systemName: "arrow.up")
        static let arrowDownImage = UIImage(named: "sortButtonImage")
        static let pencilImage = UIImage(named: "editButtonImage")
        static let pencilSlashImage = UIImage(systemName: "pencil.slash")
    }

    //MARK: - Properties

    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let searchController = UISearchController(searchResultsController: nil)
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let tableView = UITableView()
    private let navBar = UINavigationBar()
    
    private var searchNote: [NoteViewModel] = []
    private var searching = false
    private var isSwipeActive = false
    private var refresh = UIRefreshControl()
    private var timer: Timer?
    private var toDoNote: [NoteViewModel] = []
    private var addButton = UIBarButtonItem()
    private var sortButton = UIBarButtonItem()
    private var editButton = UIBarButtonItem()
    private let userDefaults = UserDefaults.standard
    
    var presenter: MainViewOutputProtocol?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        print("view did load")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did disappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        self.presenter?.viewDidAppear()
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.toDoNote.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell,
              self.toDoNote.indices.contains(indexPath.row) else {
            return UITableViewCell()
        }
        
        let note = self.toDoNote[indexPath.row]
        cell.noteName.text = note.noteName
        cell.noteDescription.text = note.description
        cell.configure(note: note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

    //MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        isSwipeActive = true
        self.editButton.isEnabled = false
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        isSwipeActive = false
        self.editButton.isEnabled = true
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let checkmarkAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (action, view, completionHander) in
            guard let self,
                    self.toDoNote.indices.contains(indexPath.row) else {
                return
            }
            self.presenter?.toggleCompletion(at: self.toDoNote[indexPath.row].id)
            completionHander(true)
        }
        checkmarkAction.backgroundColor = .lightGray
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self,
                  self.toDoNote.indices.contains(indexPath.row) else {
                print("Данные на контроллере не консистентны, был запрос на \(indexPath). Текущие данные \(self?.toDoNote)")
                return
            }
            self.presenter?.removeNoteButtonClicked(id: self.toDoNote[indexPath.row].id)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction, checkmarkAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let note = toDoNote[indexPath.row]

        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self else { return }
            let alert = CustomEditAlertView()
            alert.configure(with: note)
            alert.delegate = self
            alert.show(in: self.view)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
}

// MARK: - CustomEditAlertDelegate

extension ViewController: CustomEditAlertDelegate {
    func didEditNote(newName: String, newDescription: String?, noteID: UUID?) {
        if let id = noteID {
            presenter?.updateNoteButtonClicked(id: id, newName: newName, newDescription: newDescription)
        } else {
            presenter?.addNoteButtonClicked(noteName: newName, noteDescription: newDescription)
        }
    }
}


// MARK: - Private Methods

extension ViewController {
    
    private func configureUI() {
        self.navigationItem.title = "Notes"
        self.setupSearch()
        self.createNavBarButton()
        self.setupTableView()
        self.createRefreshController()
        self.presenter?.viewDidLoad()
    }

    private func setupTableView() {
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createRefreshController() {
        self.refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.addSubview(refresh)
    }
    
    @objc func handleRefresh() {
        refresh.endRefreshing()
    }

    private func createNavBarButton() {

        self.addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addNote(sender: )))

        self.sortButton = UIBarButtonItem(image: Constants.arrowDownImage,
                                          style: .plain, target: self,
                                          action: #selector(sortingNotesButtonAction(sender: )))

        self.editButton = UIBarButtonItem(image: Constants.pencilImage,
                                          style: .plain, target: self,
                                          action: #selector(editButton(sender: )))
 
        [addButton, sortButton, editButton].forEach { $0.tintColor = UIColor(hex: "FF8C00") }

        self.navigationItem.rightBarButtonItems = [addButton, editButton, sortButton]
        
        let font = UIFont.systemFont(ofSize: 20, weight: .bold)
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: font ]
    }

    @objc
    func addNote(sender: UIBarButtonItem) {
        let alert = CustomEditAlertView()
        alert.configure(with: nil) 
        alert.delegate = self
        alert.show(in: self.view)
    }
    
    @objc
    private func sortingNotesButtonAction(sender: UIBarButtonItem) {
        self.presenter?.sortByTitleButtonClicked()
    }
    
    @objc
    private func editButton(sender: UIBarButtonItem) {
        self.presenter?.editButtonClicked()
    }
}

//MARK: - MainViewInputProtocol

extension ViewController: MainViewInputProtocol {
    
    func updateAscendingState(isAscending: Bool) {
        sortButton.image = isAscending ? Constants.arrowDownImage : Constants.arrowUpImage
    }
    
    func updateEditingState(isEditing: Bool) {
        tableView.setEditing(isEditing, animated: true)
        editButton.image = isEditing ? Constants.pencilSlashImage : Constants.pencilImage
        tableView.visibleCells.forEach { cell in
            cell.backgroundColor = tableView.isEditing ? UIColor.systemGray6 : .systemBackground
        }
        addButton.isEnabled = !tableView.isEditing
    }
    
    func updateScreen(with notes: [NoteViewModel]) {
        self.toDoNote = notes
        tableView.reloadData()
    }
    
    func failure(error: any Error) {
        print(error.localizedDescription)
    }
}

//MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {

    private func setupSearch() {
    
        searchContainerView.backgroundColor = .white
        searchContainerView.layer.cornerRadius = 16
        searchContainerView.layer.borderColor = UIColor(hex: "FF8C00").cgColor
        searchContainerView.layer.borderWidth = 1
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.placeholder = "Find your note"
        searchTextField.borderStyle = .none
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.textColor = UIColor(hex: "9B9B9B")
        searchTextField.font = .systemFont(ofSize: 17, weight: .medium)
        searchTextField.clearButtonMode = .always
        searchTextField.returnKeyType = .done
        
        let imageView = UIImageView(image: UIImage(named: "searchGlassImage"))
        imageView.tintColor = UIColor(hex: "9B9B9B")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(imageView)
        searchContainerView.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 48),

            imageView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 18.23),
            imageView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 19.52),
            imageView.heightAnchor.constraint(equalToConstant: 19.52),

            searchTextField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10.25),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])
        
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self,
                                       action: #selector(searchTextChanged(for: )),
                                       for: .editingChanged)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
}
    
//MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    @objc func searchTextChanged(for searchText: UITextField) {
        presenter?.searchbarTextDidChange(searchText.text ?? "")
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        DispatchQueue.main.async {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

