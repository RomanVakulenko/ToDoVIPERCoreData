//
//  ToDoStorageWorker.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 06.09.2024.
//


protocol ToDoStorageWorkerProtocol {
    func fetchToDosFromDataBase(completion: @escaping (Result<TaskList, Error>) -> Void)
    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void)
}


final class ToDoStorageWorker: ToDoStorageWorkerProtocol {

    // MARK: - Private properties
    private let coreDataManager: LocalStorageManagerProtocol

    // MARK: - Init
    init(coreDataManager: LocalStorageManagerProtocol) {
        self.coreDataManager = coreDataManager
    }

    // MARK: - Public methods
    func fetchToDosFromDataBase(completion: @escaping (Result<TaskList, Error>) -> Void) {

        coreDataManager.fetchToDos { [weak self] result in
            switch result {
            case .success(let taskList):
                completion(.success(taskList))

            case .failure(let error):
                print("Failed to fetch from CoreData: \(error)")
            }
        }
    }

    func saveToDos(_ tasks: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {

        coreDataManager.saveToDos(tasks) { [weak self] result in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                print("Failed to fetch from CoreData: \(error)")
            }
        }
    }
}
