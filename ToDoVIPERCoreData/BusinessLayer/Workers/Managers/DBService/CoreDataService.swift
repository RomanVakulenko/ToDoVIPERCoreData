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

    private let persistentContainer: NSPersistentContainer
    private let queue = DispatchQueue(label: "com.coreDataService.queue", attributes: .concurrent)

    init(container: NSPersistentContainer = NSPersistentContainer(name: "ToDoVIPERCoreData")) {
        self.persistentContainer = container
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(saveContext),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc func saveContext() {
        persistentContainer.viewContext.perform {
            let context = self.persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }

    func fetchTasks(completion: @escaping (Result<DTOTaskList, Error>) -> Void) {
        queue.async {
            let context = self.persistentContainer.viewContext
            context.perform {
                let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()

//  Ошибка "NULL _cd_rawData but the object is not being turned into a fault" возникает, когда Core Data загружает объект в память, но не все данные его свойств загружены из хранилища (и тогда он битый - "fault" объект), и происходит обращение к этим данным до того, как они были загружены.

                //первый вариант устранения:
                // Disable faulting and CoreData загружает объекты полностью, вместо того чтобы загружать их по мере необходимости (faulting).
//                fetchRequest.returnsObjectsAsFaults = false

                do {
                    let taskListEntities = try context.fetch(fetchRequest)
                    guard let taskListEntity = taskListEntities.first else {
                        DispatchQueue.main.async {
                            completion(.success(DTOTaskList(todos: [], total: 0, skip: 0, limit: 0)))
                        }
                        return
                    }
                    
//Если данные уже в кэше, они будут загружены из кэша.
//Если объект является "fault", Core Data загрузит данные из хранилища при первом обращении к ним.
                    context.refresh(taskListEntity, mergeChanges: true)

                    let tasks = (taskListEntity.tasks?.allObjects as? [TaskEntity] ?? []).map {
                        DTOTask(id: Int($0.id),
                                todo: $0.todo ?? "",
                                subTitle: $0.subtitle ?? "Task subtitle",
                                timeForToDo: $0.timeForToDo ?? "введи",
                                completed: $0.completed,
                                userId: Int($0.userId))
                    }.sorted { $0.id < $1.id }

                    let dtoTaskList = DTOTaskList(todos: tasks, total: Int(taskListEntity.total), skip: Int(taskListEntity.skip), limit: Int(taskListEntity.limit))
                    DispatchQueue.main.async {
                        completion(.success(dtoTaskList))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        queue.async {
            let context = self.persistentContainer.viewContext
            context.perform {
                let fetchRequest: NSFetchRequest<TaskListEntity> = TaskListEntity.fetchRequest()
                fetchRequest.fetchLimit = 1

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
    }

    func saveTasks(_ tasks: DTOTaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            let context = self.persistentContainer.newBackgroundContext()
            context.perform {
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
}
