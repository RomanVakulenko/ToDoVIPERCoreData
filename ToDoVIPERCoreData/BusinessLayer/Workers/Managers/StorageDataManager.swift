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
    func isContextEmpty(completion: @escaping (Bool) -> Void)
    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void)
}


final class StorageDataManager: LocalStorageManagerProtocol {
    static let shared = StorageDataManager()
    private var localStorageService: LocalStorageServiceProtocol = CoreDataService.shared

    func fetchToDos(completion: @escaping (Result<TaskList, Error>) -> Void) {
        localStorageService.fetchTasks { result in
            switch result {
            case .success(let dtoTaskList):
                let tasks = dtoTaskList.todos.map { 
                    Task(from: DTOTask(id: Int($0.id),
                                       todo: $0.todo,
                                       subTitle: $0.subTitle ?? "",
                                       timeForToDo: $0.timeForToDo ?? "",
                                       completed: $0.completed,
                                       userId: Int($0.userId)))
                }
                let taskList = TaskList(tasks: tasks,
                                        total: dtoTaskList.total,
                                        skip: dtoTaskList.skip,
                                        limit: dtoTaskList.limit)
                completion(.success(taskList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func isContextEmpty(completion: @escaping (Bool) -> Void) {
        localStorageService.isContextEmpty { isEmpty in
            completion(isEmpty)
        }
    }


    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        let dtoTaskList = DTOTaskList(todos: tasks.tasks.map { task in
            DTOTask(id: task.id,
                    todo: task.description,
                    subTitle: task.subTitle,
                    timeForToDo: task.timeForToDo,
                    completed: task.isCompleted,
                    userId: task.userId)
        }, total: tasks.total, skip: tasks.skip, limit: tasks.limit)

        localStorageService.saveTasks(dtoTaskList) { result in
            completion(result)
        }
    }
}
