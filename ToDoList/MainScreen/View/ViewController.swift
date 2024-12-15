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
final class ViewController: UIViewController, UISearchBarDelegate {
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

    private var model = Model()

    private let coreDataStack = CoreDataStack()

    private var tasks: [Task]?

    private var refresh = UIRefreshControl()

    private var isFirstAppear = true

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        //tableView.separatorColor = .gray
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .blue
        tableView.reloadData()
        return tableView
    }()

    //private let addButton = UIButton()

    private var sortButton = UIBarButtonItem()

    private var editButton = UIBarButtonItem()

    //MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // обращаясь к свойствам или методам класса используй self. перед именем

        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.title = "Tasks"
        self.tableView.reloadData()

        self.createSearch()
        self.createNavBarButton()
        self.configureAppearanceNavBar()
        self.setupTableView()
        self.model.sortByTitle()
        self.createRefreshController()
        print("view did load")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did disappear")

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")

        if !self.isFirstAppear {
            self.model.toDoItems = coreDataStack.fetch()
            tableView.reloadData()
        }

        self.isFirstAppear = false
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else {
            fatalError()
        }
        
        let currentTask = model.toDoItems[indexPath.row]
        cell.itemName.text = currentTask.string
        cell.itemDescription.text = currentTask.string

        cell.accessoryType = model.toDoItems[indexPath.row].completed ? .checkmark : .none

        cell.configure(task: model.toDoItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tasks = model.toDoItems.remove(at: sourceIndexPath.row)
        model.toDoItems.insert(tasks, at: destinationIndexPath.row)
        
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
//            textField.addTarget(self, action: #selector(self.alertTextFieldDidChangeDescription(_:)), for: .editingChanged)
            textField.text = cell?.itemDescription.text
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Submit", style: .default) {
            (createAlert) in

            guard let textFields = self.alert.textFields, textFields.count > 0,
                  let textValue = self.alert.textFields?[0].text,
                  let textValueDes = self.alert.textFields?[1].text else { return }
        
            self.model.updateItem(at: indexPath.row, with: textValue, with: textValueDes)
            
        self.tableView.reloadData()
        }
        
        alert.addAction(cancelAlertAction)
        alert.addAction(editAlertAction)
        present(alert, animated: true, completion: nil)
    }

/*    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.toDoItems.remove(at: indexPath.row)
            let commit = model.toDoItems[
            tableView.deleteRows(at: [indexPath], with: .fade)

            CoreDataStack.saveContextIfChanged()
        }
    }
*/
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
            self?.model.removeItem(index: indexPath.row)
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

    private func createSearch() {
        searchController.searchBar.placeholder = "Find your task"

        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        searchController.searchBar.delegate = self
    }

    private func configureAppearanceNavBar() {
        navBar.navigationBar.backgroundColor = .lightGray
        navBar.navigationBar.isTranslucent = false
        //navBar.navigationBar.addBottomBorder(with: , height: 1)

    }
    
    /*@objc
    private func addTask(sender: UIButton) {

        self.alert = UIAlertController(title: "Create new task", message: nil, preferredStyle: .alert)
        
        self.alert.addTextField { textField in
            textField.placeholder = "Put your task here"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_ :)), for: .editingChanged)
        }
        
        let createAlertAction = UIAlertAction(title: "Create", style: .default) {
            (createAlert) in
            
            guard let unwrTextFieldValue = self.alert.textFields?[0].text,
                  let unweTextDescription = self.alert.textFields?[1].text else { return }

            self.model.addItem(itemName: unwrTextFieldValue, itemDescription: unweTextDescription)
            self.model.sortByTitle()
            self.tableView.reloadData()
        }

        self.alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Description"
//            textField.addTarget(self, action: #selector(self.alertTextFieldDidChangeDescription(_:)), for: .editingChanged)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)


        self.alert.addAction(cancelAlertAction)
        self.alert.addAction(createAlertAction)
        self.present(self.alert, animated: true, completion: nil)
        createAlertAction.isEnabled = false
    }*/

    @objc func addTask(sender: UIBarButtonItem) {
        let taskView = TaskViewController()
        navigationController?.pushViewController(taskView, animated: true)
        self.tableView.reloadData()
        self.model.sortByTitle()
        //navBar.pushViewController(taskView, animated: true)
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

        sortButton.image = model.sortedAscending ? Constants.arrowUpImage : Constants.arrowDownImage

        model.sortedAscending = !model.sortedAscending

        model.sortByTitle()

        tableView.reloadData()
    }
    
    @objc
    private func editButton(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        model.editButtonClicked = !model.editButtonClicked
        editButton.image = model.editButtonClicked ? Constants.pencilSlashImage : Constants.pencilImage
    }
}
