//
//  ToDoInteractor.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import Foundation
import CoreData


protocol ToDoInteractorProtocol: AnyObject {
    var presenter: ToDoPresenterProtocol? { get set }
    var taskList: TaskList? { get set }

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request)
}


final class ToDoInteractor: ToDoInteractorProtocol {

    // MARK: - Public properties
    weak var presenter: ToDoPresenterProtocol?
    var taskList: TaskList?

    // MARK: - Private properties
    private let networkWorker: ToDoNetworkWorkerProtocol
    private let storageWorker: ToDoStorageWorkerProtocol

    // MARK: - Init
    init(networkWorker: ToDoNetworkWorkerProtocol,
         storageWorker: ToDoStorageWorkerProtocol) {
        self.networkWorker = networkWorker
        self.storageWorker = storageWorker
    }

    // MARK: - Public methods

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request) {
        if let taskList = taskList {
            fetchToDosFromDB()
        } else {
            loadToDosFromNet()
        }
    }

    // MARK: - Private methods

    private func fetchToDosFromDB() {
        storageWorker.fetchToDosFromDataBase { [weak self] result in
            switch result {
            case .success(let taskList):
                if taskList.tasks.isEmpty {
                    self?.loadToDosFromNet()
                } else {
                    self?.taskList = taskList
                    self?.presenter?.presentToDoList(response: ToDoScreenFlow.OnDidLoadViews.Response(taskList: taskList))
                }
            case .failure(let error):
                print("Failed to load data from DB: \(error)")
                self?.loadToDosFromNet()
            }
        }
    }

   private func loadToDosFromNet() {
       networkWorker.loadToDosFromNetwork { [weak self] result in
           switch result {
           case .success(let taskList):
               self?.taskList = taskList
               self?.presenter?.presentToDoList(response: ToDoScreenFlow.OnDidLoadViews.Response(taskList: taskList))
               self?.storageWorker.saveToDos(taskList) { saveResult in
                   switch saveResult {
                   case .success:
                       print("Data saved to DB successfully.")
                   case .failure(let error):
                       print("Failed to save data to DB: \(error)")
                   }
               }
           case .failure(let error):
               print("Failed to load data from network: \(error)")
           }
       }
   }

}





// запрашиваем из сервиса (из БД), если нет - то из сети

// интерактор достань данные из локального хранилища (LocalStorageWorker), обращается к воркеру (сервис), воркер(сервис) обращается к менеджерам (сеть/ БД) и возвращает в интерактор данные

//если нет в БД - воркер сделай запрос в сеть (NetworkWorker)

//по иерархии интреактор - воркер, воркер на менеджер, менеджер к сервису

//интерактор решает пойти в сеть или в БД, обращается к воркеру

// в менеджере вызову инит Бизнес модели и из DTO в нее конвертирую
