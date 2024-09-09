//
//  StorageDataManager.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import CoreData
import UIKit

protocol LocalStorageManagerProtocol {
    func fetchToDos(completion: @escaping (Result<TaskList, Error>) -> Void)
    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void)
}


final class StorageDataManager: LocalStorageManagerProtocol {
    static let shared = StorageDataManager()

    // MARK: - Private properties
    private var persistentContainer: NSPersistentContainer {
        return CoreDataService.shared.persistentContainer
    }
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }


    // MARK: - Public methods
    // конвертирует ее в бизнес-модель
    func fetchToDos(completion: @escaping (Result<TaskList, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()

        DispatchQueue.global().async {
            do {
                let taskListEntities = try self.context.fetch(fetchRequest)

                guard let taskListEntity = taskListEntities.first else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "StorageDataManagerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "No TaskListEntity found"])))
                    }
                    return
                }

                guard let todos = taskListEntity.tasks as? Set<TaskEntity> else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "StorageDataManagerError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to cast tasks"])))
                    }
                    return
                }
                let taskArray = todos.map { Task(from: DTOTask(id: Int($0.id),
                                                                todo: $0.todo ?? "",
                                                                completed: $0.completed,
                                                                userId: Int($0.userId))) }
                let taskList = TaskList(tasks: taskArray, 
                                        total: taskArray.count,
                                        skip: Int(taskListEntity.skip),
                                        limit: Int(taskListEntity.limit))
                DispatchQueue.main.async {
                    completion(.success(taskList))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext() //system concurrent queue

        backgroundContext.perform {
            do {
                // Удаляем старые
                let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()
                let existingTaskLists = try backgroundContext.fetch(fetchRequest)
                for taskList in existingTaskLists {
                    backgroundContext.delete(taskList)
                }
                // Сохраняем новые
                let taskListEntity = TaskListEntity(context: backgroundContext)
                taskListEntity.skip = Int64(tasks.skip)
                taskListEntity.limit = Int64(tasks.limit)
                taskListEntity.total = Int64(tasks.total)

                for task in tasks.tasks {
                    let taskEntity = TaskEntity(context: backgroundContext)
                    taskEntity.id = Int64(task.id)
                    taskEntity.todo = task.description
                    taskEntity.completed = task.isCompleted
                    taskEntity.userId = Int64(task.userId)
                    taskListEntity.addToTasks(taskEntity)
                }

                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}



