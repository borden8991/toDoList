//
//  ViewController.swift
//  ToDoList
//
//  Created by user270963 on 11/8/24.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    //MARK: -Properties
    
    var storage: TaskStorageProtocol?
    
    let searchController = UISearchController()
    
    var alert = UIAlertController()
    
    let navBar = UINavigationController()
     
    var task = Model()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        //tableView.separatorColor = .blue
        return tableView
    }()
    
    let editButton = UIButton()
    
    func loadTasks() {
        task.toDoItems = storage?.load() as! [Item]
    }
    
    
    //MARK: -Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
       
        storage = TaskStorage()
        loadTasks()
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.searchBar.placeholder = "Find your task"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        
        self.navigationItem.title = "Tasks"
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(edit(sender: )))
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask(sender: )))
        
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.down"), style: .plain, target: self, action: #selector(sortingTasksButtonAction(sender: )))
        
        self.navigationItem.rightBarButtonItems = [addButton, editButton, sortButton]
    
        configureAppearanceNavBar()
        
        setupTableView()
        
        tableView.separatorColor = .gray
        tableView.sectionHeaderHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        task.sortByTitle()
        tableView.reloadData()
        
    }
}

//MARK: -UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return task.toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier, for: indexPath) as? CustomCell else { fatalError() }
        
        cell.delegate = self
        
        let currentTask = task.toDoItems[indexPath.row]
        cell.itemName.text = currentTask.string
        cell.itemDescription.text = currentTask.string
        
        cell.accessoryType = currentTask.completed ? .checkmark : .none
        
        cell.configure(task: task.toDoItems[indexPath.row])
         
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tasks = task.toDoItems.remove(at: sourceIndexPath.row)
        task.toDoItems.insert(tasks, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (action, view, completionHandler) in
            self?.editCellContent(indexPath: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func editCellContent(indexPath: IndexPath) {
        let cell = tableView(tableView, cellForRowAt: indexPath) as? CustomCell
        
        alert = UIAlertController(title: "Edit your task", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            textField.text = cell?.itemName.text
        })
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            textField.text = cell?.itemDescription.text
        })
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let editAlertAction = UIAlertAction(title: "Submit", style: .default) {
            (createAlert) in
            
            guard let textFields = self.alert.textFields, textFields.count > 0 else { return }
            
            guard let textValue = self.alert.textFields?[0].text else { return }
            
            guard let textValueDes = self.alert.textFields?[1].text else { return }
        
            self.task.updateItem(at: indexPath.row, with: textValue, with: textValueDes)
            
        self.tableView.reloadData()
        }
        alert.addAction(cancelAlertAction)
        alert.addAction(editAlertAction)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate {
    
   /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if task.changeState(at: indexPath.row) == true {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }*/
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let checkmarkAction = UIContextualAction(style: .normal, title: "Done") { [weak self] (action, view, completionHander) in
            self?.checkmarkAdd(indexPath: indexPath)
            completionHander(true)
        }
        checkmarkAction.backgroundColor = .lightGray
        
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.task.toDoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction, checkmarkAction])
    }
    
    func checkmarkAdd(indexPath: IndexPath) {
        _ = tableView(tableView, cellForRowAt: indexPath) as? CustomCell
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none }
        else { tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
    }
}

extension ViewController {
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func edit(sender: UIButton) {
        tableView.isEditing.toggle()
        //tableView.setTitle(tableView.isEditing ? "End edit" : "Edit", for: .normal)
    }
    
    /*func addBottomBorder(with color: UIColor, height: CGFloat) {
     let separator = UIView()
     separator.backgroundColor = color
     separator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
     separator.frame = CGRect(x: 0,
     y: frame.height - height,
     width: frame.width,
     height: height)
     }*/
    
    func configureAppearanceNavBar() {
        navBar.navigationBar.backgroundColor = .lightGray
        navBar.navigationBar.isTranslucent = false
        //navBar.navigationBar.addBottomBorder(with: , height: 1)
        
    }
    
    @objc func addTask(sender: UIButton) {
        
        self.alert = UIAlertController(title: "Create new task", message: nil, preferredStyle: .alert)
        
        self.alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Put your task here"
            //textField.placeholder = "Discription"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_ :)), for: .editingChanged)
        }
        
        let createAlertAction = UIAlertAction(title: "Create", style: .default) {
            (createAlert) in
            
            guard let unwrTextFieldValue = self.alert.textFields?[0].text else { return }
            
            guard let unweTextDescription =
                    self.alert.textFields?[1].text else { return }
            
            self.task.addItem(itemName: unwrTextFieldValue, itemDescription: unweTextDescription)
            self.task.sortByTitle()
            self.tableView.reloadData()
        }
        
        self.alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Discription"
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        self.alert.addAction(cancelAlertAction)
        self.alert.addAction(createAlertAction)
        self.present(self.alert, animated: true, completion: nil)
        createAlertAction.isEnabled = false
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        guard let senderText = sender.text, alert.actions.indices.contains(1) else {
            return
        }
        
        let action = alert.actions[1]
        action.isEnabled = senderText.count > 0
    }
    
    @objc func sortingTasksButtonAction(sender: UIButton) {
        let arrowUp = UIImage(systemName: "arrow.up")
        let arrowDown = UIImage(systemName: "arrow.down")
        
        task.sortedAscending = !task.sortedAscending
        //sortButton.image = task.sortedAscending ? arrowUp : arrowDown
        
        task.sortByTitle()
        
        tableView.reloadData()
        
    }
    
    @objc func editButton(_ sender: UIBarItem) {
        let editOn = UIImage(systemName: "pencil.slash")
        let editOff = UIImage(systemName: "pencil")
        tableView.setEditing(tableView.isEditing, animated: true)
        
        task.editButtonClicked = !task.editButtonClicked
        //editButton.image = task.editButtonClicked ? editOn : editOff
    }
}

extension ViewController: CustomCellDelegate {
    
    func deleteCell(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)
        
        guard let unwrIndexPath = indexPath else { return }
        
        task.removeItem(at: unwrIndexPath.row)
        tableView.reloadData()
    }
    
    func editCell(cell: CustomCell) {
        let indexPath = tableView.indexPath(for: cell)
        
        guard let unwrIndexPath = indexPath else { return }
        
        self.editCellContent(indexPath: unwrIndexPath)
    }
}
