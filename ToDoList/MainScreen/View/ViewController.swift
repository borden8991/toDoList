//
//  ViewController.swift
//  ToDoList
//
//  Created by user270963 on 11/8/24.
//

import UIKit
import CoreData

// Перевести на МВП
// дополнить кор дату - удаление как минимум, и было бы круто добавить изменение
// + изучить как работают NSFetchRequest (сортировки, фильтрации, лимиты, оффсеты)
// закрыть кор дату протоколом
// попытаться понять, что происходит в комплишене метода container.loadPersistentStores
// попробовать добавить еще один объект кор даты(хз ченить
final class ViewController: UIViewController {
    
    
    // MARK: - Constants
    // почему для этого лучше использовать enum а не struct?
    private enum Constants {
        static let arrowUpImage = UIImage(systemName: "arrow.up")
        static let arrowDownImage = UIImage(systemName: "arrow.down")
        static let pencilImage = UIImage(systemName: "pencil")
        static let pencilSlashImage = UIImage(systemName: "pencil.slash")
    }

    //MARK: - Properties

    private let searchController = UISearchController()

    private var alert = UIAlertController()

    private let navBar = UINavigationController()

//    private var model = Model()
    
    private var refresh = UIRefreshControl()
    
    let userDefaults = UserDefaults.standard
    
    var presenter: MainViewOutputProtocol?
    
    private var toDoItems: [Item] = []
    
    var searching = false

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        //tableView.separatorColor = .gray
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .systemBlue
        return tableView
    }()

    private var sortButton = UIBarButtonItem()

    private var editButton = UIBarButtonItem()

    //MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationItem.title = "Tasks"

        self.createSearch()
        self.createNavBarButton()
        self.configureAppearanceNavBar()
        self.setupTableView()
        self.createRefreshController()
        print("view did load")
        
        self.presenter?.viewDidLoad()
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
        self.toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {
            fatalError()
        }
        
        let currentTask = self.toDoItems[indexPath.row]
        cell.itemName.text = currentTask.itemName
        cell.itemDescription.text = currentTask.itemName
        //cell.itemCompleted = currentTask.completed
        cell.accessoryType = self.toDoItems[indexPath.row].completed ? .checkmark : .none
        
        cell.configure(task: self.toDoItems[indexPath.row])
        
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tasks = self.toDoItems.remove(at: sourceIndexPath.row)
        self.toDoItems.insert(tasks, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    func editCellContent(indexPath: IndexPath) {
        let cell = tableView(tableView, cellForRowAt: indexPath) as? CustomCell
        
        alert = UIAlertController(title: "Edit your task", message: nil, preferredStyle: .alert)

        alert.addTextField(configurationHandler: { [weak self] (textField) -> Void in
            textField.addTarget(self, action: #selector(self?.alertTextFieldDidChange(_:)), for: .editingChanged)
            textField.text = cell?.itemName.text
        })
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = cell?.itemDescription.text
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Submit", style: .default) {
            (createAlert) in

            guard let textFields = self.alert.textFields, textFields.count > 0,
                  let textValue = self.alert.textFields?[0].text,
                  let textValueDes = self.alert.textFields?[1].text else { return }
        // TODO: - Вынести логику обновления айтема в презентер
            //self.model.updateItem(newName: textValue, newDescription: textValueDes)
            
        self.tableView.reloadData()
        }
        // TODO: - Вынести логику удаления айтема в презентер
       // self.model.removeItem(index: indexPath.row)
        
        alert.addAction(cancelAlertAction)
        alert.addAction(editAlertAction)
        present(alert, animated: true, completion: nil)
    }
}

    //MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkmarkAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (action, view, completionHander) in
           self?.checkmarkAdd(indexPath: indexPath)
            completionHander(true)
        }
        checkmarkAction.backgroundColor = .lightGray
        
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            // TODO: - Вынести логику удаления айтема в презентер
           // self?.model.removeItem(index: indexPath.row)
            self?.tableView.reloadData()
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

    func checkmarkAdd(indexPath: IndexPath) {

        // TODO: - Вынести логику добавления галки в презентер
        //self.model.changeState(index: indexPath.row)
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
    }
}

// MARK: - Private Methods

extension ViewController {

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func createRefreshController() {
        self.refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.addSubview(refresh)
    }
        @objc func handleRefresh() {
            refresh.endRefreshing()
        }

    private func createNavBarButton() {

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask(sender: )))

        self.sortButton = UIBarButtonItem(image: Constants.arrowDownImage, style: .plain, target: self, action: #selector(sortingTasksButtonAction(sender: )))

        self.editButton = UIBarButtonItem(image: Constants.pencilImage, style: .plain, target: self, action: #selector(editButton(sender: )))

        self.navigationItem.rightBarButtonItems = [addButton, editButton, sortButton]
    }



    private func configureAppearanceNavBar() {
        navBar.navigationBar.backgroundColor = .lightGray
        navBar.navigationBar.isTranslucent = false
    }

    @objc func addTask(sender: UIBarButtonItem) {
        let vc = AddTaskScreenBuilder.createAddTaskScreen()
        navigationController?.pushViewController(vc, animated: true)
        self.tableView.reloadData()
        // TODO: - Вынести логику сортировки айтемов в презентер
        //self.model.sortByTitle()
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
    private func sortingTasksButtonAction(sender: UIBarButtonItem) {

        // TODO: - Вынести логику сортировки айтемов в презентер
//        sortButton.image = model.sortedAscending ? Constants.arrowUpImage : Constants.arrowDownImage
//
//        model.sortedAscending = !model.sortedAscending
//
//        model.sortByTitle()

        tableView.reloadData()
    }
    
    @objc
    private func editButton(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        // TODO: - Вынести логику изменения айтема в презентер
//        model.editButtonClicked = !model.editButtonClicked
//        editButton.image = model.editButtonClicked ? Constants.pencilSlashImage : Constants.pencilImage
    }
}

extension ViewController: MainViewInputProtocol {
    func updateScreen(with items: [Item]) {
        self.toDoItems = items
        tableView.reloadData()
    }
    
//    func updateScreen() {
//        tableView.reloadData()
//        print("success")
//    }
    
    func failure(error: any Error) {
        print(error.localizedDescription)
    }
}

extension ViewController: UISearchBarDelegate {
    /*func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG: ", searchController.searchBar.text ?? " ")
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text else { return }
        filterForSearch(searchText: searchText)
    }
    
    func filterForSearch(searchText: String) {
        model.filteredToDoItems = model.toDoItems.filter {
            $0.itemName.lowercased().contains(searchText.lowercased())
        }
        self.tableView.reloadData()
    }*/
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        model.filteredToDoItems = model.toDoItems.filter({
//                $0.itemName.lowercased().prefix(searchText.count) == searchText.lowercased()
//            })
//        searching = true
//        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        self.tableView.reloadData()
    }
    private func createSearch() {
        
        self.searchController.searchBar.placeholder = "Find your task"
        self.searchController.obscuresBackgroundDuringPresentation = false
        //self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.enablesReturnKeyAutomatically = false
        //self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
}
