//
//  CoreDataService.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 06.09.2024.
//

import Foundation
import CoreData
import UIKit


protocol LocalStorageServiceProtocol {
    func fetchTasks(completion: @escaping (Result<DTOTaskList, Error>) -> Void)
    func saveTasks(_ tasks: DTOTaskList, completion: @escaping (Result<Void, Error>) -> Void)
    func isContextEmpty(completion: @escaping (Bool) -> Void)
}


final class CoreDataService: LocalStorageServiceProtocol {

    static let shared: LocalStorageServiceProtocol = CoreDataService()
    private init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveContext),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoVIPERCoreData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    @objc func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchTasks(completion: @escaping (Result<DTOTaskList, Error>) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()

        do {
            let taskListEntities = try context.fetch(fetchRequest)
            guard let taskListEntity = taskListEntities.first else {
                completion(.success(DTOTaskList(todos: [], total: 0, skip: 0, limit: 0)))
                return
            }

            let tasks = (taskListEntity.tasks?.allObjects as? [TaskEntity] ?? []).map {
                DTOTask(id: Int($0.id),
                        todo: $0.todo ?? "",
                        subTitle: $0.subtitle ?? "",
                        timeForToDo: $0.timeForToDo ?? "",
                        completed: $0.completed,
                        userId: Int($0.userId))
            }.sorted { $0.id < $1.id }

            let dtoTaskList = DTOTaskList(todos: tasks, total: Int(taskListEntity.total), skip: Int(taskListEntity.skip), limit: Int(taskListEntity.limit))
            completion(.success(dtoTaskList))
        } catch {
            completion(.failure(error))
        }
    }

    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()
        fetchRequest.fetchLimit = 1

        DispatchQueue.global().async {
            do {
                let count = try context.count(for: fetchRequest)
                let isEmpty = count == 0
                DispatchQueue.main.async {
                    completion(isEmpty)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }


    func saveTasks(_ tasks: DTOTaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()
        if let existingTaskLists = try? context.fetch(fetchRequest) {
            for taskList in existingTaskLists {
                context.delete(taskList)
            }
        }

        let taskListEntity = TaskListEntity(context: context)
        taskListEntity.total = Int64(tasks.total)
        taskListEntity.skip = Int64(tasks.skip)
        taskListEntity.limit = Int64(tasks.limit)

        for task in tasks.todos {
            let taskEntity = TaskEntity(context: context)
            taskEntity.id = Int64(task.id)
            taskEntity.todo = task.todo
            taskEntity.subtitle = task.subTitle
            taskEntity.timeForToDo = task.timeForToDo
            taskEntity.completed = task.completed
            taskEntity.userId = Int64(task.userId)
            taskEntity.taskList = taskListEntity
        }

        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
