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
        static let arrowDownImage = UIImage(systemName: "arrow.down")
        static let pencilImage = UIImage(systemName: "pencil")
        static let pencilSlashImage = UIImage(systemName: "pencil.slash")
    }

    //MARK: - Properties

    private let nameLabel = UILabel()
    
    private let dateLabel = UILabel()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var searchNote: [NoteViewModel] = []
    
    private var searching = false

    private var alert = UIAlertController()
    
    private var refresh = UIRefreshControl()
    
    private let navBar = UINavigationBar()
    
    private var timer: Timer?

    private var toDoNote: [NoteViewModel] = []
    
    private var addButton = UIBarButtonItem()

    private var sortButton = UIBarButtonItem()

    private var editButton = UIBarButtonItem()
    
    private var isSwipeActive = false

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .systemBlue
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        return tableView
    }()
    
    var presenter: MainViewOutputProtocol?
    
    let userDefaults = UserDefaults.standard

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationItem.title = "Notes"

        self.createSearch()
        self.createNavBarButton()
        self.setupTableView()
        self.createRefreshController()
        self.presenter?.viewDidLoad()
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
        
        if tableView.isEditing {
            
        }
        
        let note = self.toDoNote[indexPath.row]
        cell.noteName.text = note.noteName
        cell.noteDescription.text = note.description
        cell.accessoryType = note.completed ? .checkmark : .none
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
        
    func editCellContent(indexPath: IndexPath) {
        
        let cell = tableView(tableView, cellForRowAt: indexPath) as? CustomCell
        
        alert = UIAlertController(title: "Edit your note", message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: { [weak self] (textField) -> Void in
            textField.addTarget(self, action: #selector(self?.alertTextFieldDidChange(_:)), for: .editingChanged)
            textField.text = cell?.noteName.text
        })
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = cell?.noteDescription.text
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Submit", style: .default) { [weak self]
            createAlert in
            guard let self else { return }
            let newDescription = self.alert.textFields?.last?.text ?? ""
            if let newName = self.alert.textFields?.first?.text,
               !newName.isEmpty,
               self.toDoNote.indices.contains(indexPath.row) {
                self.presenter?.updateNoteButtonClicked(id: self.toDoNote[indexPath.row].id, newName: newName, newDescription: newDescription)
            }
            self.updateScreen(with: self.toDoNote)
        }
        alert.addAction(cancelAlertAction)
        alert.addAction(editAlertAction)
        present(alert, animated: true, completion: nil)
    }
}

    //MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    // Когда свайп начинает показываться (система)
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        isSwipeActive = true
        self.editButton.isEnabled = false
    }

    // Когда свайп скрывается (пользователь закончил)
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
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editCellContent(indexPath: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue

        return UISwipeActionsConfiguration(actions: [editAction])
    }
}

// MARK: - Private Methods

extension ViewController {

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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

        self.navigationItem.rightBarButtonItems = [addButton, editButton, sortButton]
    }

    @objc
    func addNote(sender: UIBarButtonItem) {
        let vc = AddNoteScreenBuilder.createAddNoteScreen()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc
    private func alertTextFieldDidChange(_ sender: UITextField) {
        guard let senderText = sender.text, alert.actions.indices.contains(1) else {
            return
        }
        let action = alert.actions[1]
        action.isEnabled = senderText.count > 0
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
        sortButton.image = isAscending ? Constants.arrowUpImage : Constants.arrowDownImage
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty == false {
            searching = true
            searchNote = toDoNote.filter({ $0.noteName.lowercased().uppercased().prefix(searchText.count) == searchText.lowercased().uppercased()})
            self.updateScreen(with: self.toDoNote)
        } else {
            searching = false
            self.updateScreen(with: toDoNote)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        self.updateScreen(with: toDoNote)
    }
    
    private func createSearch() {
        
        self.searchController.searchBar.placeholder = "Find your note"
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.enablesReturnKeyAutomatically = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
}

//MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.searchbarTextDidChange(searchController.searchBar.text ?? "")
    }
}

