//
//  MainPresenter.swift
//  ToDoList
//
//  Created by Denis Borovoi on 16.12.2024.
//

import Foundation

protocol MainViewInputProtocol: AnyObject {
    
    /// Обновить экран с сохраненными задачами.
    /// - Parameter notes: Массив задач.
    func updateScreen(with notes: [NoteViewModel])
    
    func failure(error: Error)
    
    /// Обновить экран с состоянием изменения всех записей.
    /// - Parameter isEditing: Редактируется ли.
    func updateEditingState(isEditing: Bool)
    
    /// Обновить экран с измененным порядом задач.
    /// - Parameter isAscending: A-Z / Z-A
    func updateAscendingState(isAscending: Bool)
}

final class MainPresenter {
    
    // MARK: - Private properites
    
    private let coreDataStack = CoreDataStack()
    private let userDefaults = UserDefaults.standard
    
    weak private var view: MainViewInputProtocol?
    
    private var isFirstAppear = true
    private var toDoNotes: [NoteViewModel] = []
    private var isEditing: Bool = false
    private var isSearching: Bool = false
    private var currentSearchText: String = ""
    private var isAscending: Bool {
        userDefaults.bool(forKey: "sortOrderAscending")
    }
    
    // MARK: - Init
    
    init(view: MainViewInputProtocol) {
        self.view = view
    }
}

// MARK: - Private methods

extension MainPresenter {

    private func fetchNotes() {
        if isSearching {
            self.toDoNotes = self.coreDataStack.fetch(with: self.currentSearchText,
                                                      isAscending: self.isAscending)
            self.view?.updateScreen(with: self.toDoNotes)
        } else {
            self.toDoNotes = self.coreDataStack.fetch(with: nil,
                                                      isAscending: self.isAscending)
            self.view?.updateScreen(with: self.toDoNotes)
        }
    }
    
    private func removeNote(at id: UUID) {
        self.coreDataStack.deleteNote(id)
        self.toDoNotes = self.coreDataStack.fetch(with: self.currentSearchText,
                                                  isAscending: self.isAscending)
        self.view?.updateScreen(with: self.toDoNotes)
    }
    
    private func updateNote(at id: UUID, newName: String, newDescription: String?) {
        self.coreDataStack.updateNote(id: id,
                                      title: newName,
                                      description: newDescription)
        self.fetchNotes()
    }
    
    private func sortOrder() {
        let currentAscendingState = self.isAscending
        userDefaults.set(!currentAscendingState, forKey: "isAscending")
        self.fetchNotes()
        self.view?.updateAscendingState(isAscending: currentAscendingState)
    }
    
    private func updateSearchResults(filter text: String) {
        self.fetchNotes()
    }
}

// MARK: - MainViewOutputProtocol

extension MainPresenter: MainViewOutputProtocol {

    func editButtonClicked() {
        self.isEditing.toggle()
        self.view?.updateEditingState(isEditing: self.isEditing)
    }
    
    func sortByTitleButtonClicked() {
        let newIsAscending = !userDefaults.bool(forKey: "sortOrderAscending")
        userDefaults.set(newIsAscending, forKey: "sortOrderAscending")
        sortOrder()
    }
    
    func removeNoteButtonClicked(id: UUID) {
        self.removeNote(at: id)
    }
    
    func updateNoteButtonClicked(id: UUID, newName: String, newDescription: String?) {
        self.updateNote(at: id,
                        newName: newName,
                        newDescription: newDescription)
    }
    
    func viewDidLoad() {
        self.fetchNotes()
        self.view?.updateScreen(with: self.toDoNotes)
        sortOrder()
    }
    
    func viewDidAppear() {
        if !self.isFirstAppear {
            self.fetchNotes()
            self.view?.updateScreen(with: self.toDoNotes)
        }
        self.isFirstAppear = false
    }
    
    func searchbarTextDidChange(_ text: String) {
        self.currentSearchText = text
        self.isSearching = !text.isEmpty
        self.fetchNotes()
    }
    
    func toggleCompletion(at id: UUID) {
        coreDataStack.toggleNoteCompletion(id)
        self.fetchNotes()
    }
}


