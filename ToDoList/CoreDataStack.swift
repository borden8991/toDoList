//
//  CoreDataStack.swift
//  ToDoList
//
//  Created by Vasily Maslov on 24.11.2024.
//

import Foundation
import CoreData

final class CoreDataStack {

    // MARK: - Private Properties

    private let persistentContainer: NSPersistentContainer

    var itemTask: [Item]?

    // MARK: - Public Properties

    public let context: NSManagedObjectContext

    // MARK: - Init

    public init() {
        guard let modelUrl = Bundle.main.url(forResource: "ToDoList", withExtension: "momd") else {
            fatalError("Невозможно загрузить CoreData модель")
        }

        let container = NSPersistentContainer(name: "ToDoList")
        let description = NSPersistentStoreDescription()
        //        description.shouldMigrateStoreAutomatically = true
        //        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions.append(description)
        container.loadPersistentStores { persistanceStoreDescription, error in
            // error триггерится если не срабатывает lightweight миграция и тогда удаляется текущая sqlite моделька и создается новая ей на замену
            //            if let error {
            //                NSLog("CoreData. Ошибка загрузки \(error)")
            //                do {
            //                    try container.persistentStoreCoordinator.destroyPersistentStore(at: modelUrl, type: .sqlite)
            //                    _ = try container.persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: modelUrl)
            //                } catch {
            //                    NSLog("CoreData. Ошибка создания или загрузки SQLite модели в persistent store: \(error.localizedDescription)")
            //                }
            //            } else {
            //                NSLog("CoreData. persistentStore успешно загружен \(persistanceStoreDescription.type)")
            //            }
        }
        persistentContainer = container

        self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.context.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        self.context.mergePolicy = NSMergePolicy.overwrite
        self.context.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Public Methods

    public func saveContextIfChanged() {
        self.context.performAndWait {
            do {
                try self.context.save()
            } catch {
                print("Unable to save context: \(error)")
            }
        }
    }

    public func fetch() -> [Item] {
        let request = NSFetchRequest<Task>(entityName: "Task")

        var entities: [Item]?

        // .perform(schedule: .enqueued) выполняет задачи в порядке очереди добавления в контекст, то есть синхронно, как .performAndWait() для не async/await версии. Дефолтное значение метода - .immediate, обеспечивает асинхронное выполнение задач(в момент добавления)

        context.performAndWait {
            do {
                request.returnsObjectsAsFaults = false
                let result = try context.fetch(request)
                entities = result.map {
                    Item(string: $0.itemName,
                         descriprion: $0.itemDescription ?? "",
                         completed: $0.itemCompleted)
                }
            } catch {
                entities = nil
            }
        }
        //
        //                request.predicate = fetchConfiguration?.predicate
        //                request.sortDescriptors = fetchConfiguration?.sortDescriptors
        //                request.fetchLimit = fetchConfiguration?.fetchLimit ?? 0
        //                request.fetchOffset = fetchConfiguration?.fetchOffset ?? 0
        return entities ?? []
    }

    public func createItem(_ item: Item) {
        let task = Task(context: context)
        task.itemName = item.string
        task.itemDescription = item.description
        task.itemCompleted = item.completed

        self.saveContextIfChanged()

    }

    public func deleteItem(with task: Item) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        do {
            guard let tasks = try? context.fetch(fetchRequest) as? [Task],
                  let itemTask = tasks.first(where: { $0.itemName == task.string }) else { return }
            context.delete(itemTask)
        }
        saveContextIfChanged()
        /*let fetchRequest = try self.createItem(_: item)

            let tasks = try? context.fetch(fetchRequest)
        tasks.forEach {
            context.delete($0)
        }
        try context.saveContextIfChanged()
        }
                    //let task = tasks.first(where: { $0 == index })
            self.saveContextIfChanged()*/
    }

    func updateItem(_ item: Item) {
        let task = Task(context: context)
        task.itemName = item.string
        task.itemDescription = item.description
        task.itemCompleted = item.completed
        
        self.saveContextIfChanged()
    }
}
