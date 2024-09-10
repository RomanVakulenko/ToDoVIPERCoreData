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
    var taskListFromNetOrDB: TaskList? { get set }

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request)
    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request)
    func didTapCheckMarkWith(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)
    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)

    func useTextViewText(request: ToDoScreenFlow.OnTextChanged.Request)
}


protocol ToDoInteractorDataStore: AnyObject {
    var taskList: TaskList? { get }
}


final class ToDoInteractor: ToDoInteractorProtocol {

    // MARK: - Public properties
    weak var presenter: ToDoPresenterProtocol?
    var taskListFromNetOrDB: TaskList?
    var filteredTasksListForUI: TaskList?
    var totalTasks = 0
    var completedTasksAmount: Int?

    // MARK: - Private properties
    private let networkWorker: ToDoNetworkWorkerProtocol
    private let storageWorker: ToDoStorageWorkerProtocol

    private var filterType = ToDoModel.FilterType.all

    // MARK: - Init
    init(networkWorker: ToDoNetworkWorkerProtocol,
         storageWorker: ToDoStorageWorkerProtocol) {
        self.networkWorker = networkWorker
        self.storageWorker = storageWorker
    }

    // MARK: - Public methods

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request) {
        storageWorker.isDBEmpty() { [weak self] isEmpty in
            guard let self = self else { return }
            if isEmpty {
                loadToDosFromNet()
            } else {
                fetchToDosFromDB()
            }
        }
    }


    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request) {
        filterType = request.filterType

        filteredTasksListForUI = makeFilteredListFromOriginalBy(filterType: filterType)

        if let filteredListForUI = self.filteredTasksListForUI {
            presenterUpdateUIWith(taskList: filteredListForUI)
        }
    }


    func didTapCheckMarkWith(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {
        guard let taskList = self.taskListFromNetOrDB else { return }
        var tasks = taskList.tasks

        for (index, task) in tasks.enumerated() {
            if String(task.id) == request.id {
                self.taskListFromNetOrDB?.tasks[index].isCompleted.toggle()
            }
        }

        filteredTasksListForUI = makeFilteredListFromOriginalBy(filterType: filterType)
        if let filteredListForUI = self.filteredTasksListForUI {
            presenterUpdateUIWith(taskList: filteredListForUI)
        }

        if let taskListWithNewMarkForSave = self.taskListFromNetOrDB {
            saveChanged(taskListForSave: taskListWithNewMarkForSave)
        }
    }


    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {
        self.taskListFromNetOrDB?.tasks.removeAll(where: { String($0.id) == request.id })
        self.totalTasks -= 1

        filteredTasksListForUI = makeFilteredListFromOriginalBy(filterType: filterType)
        if let filteredListForUI = self.filteredTasksListForUI {
            presenterUpdateUIWith(taskList: filteredListForUI)
        }

        if let changedTaskList = self.taskListFromNetOrDB {
            saveChanged(taskListForSave: changedTaskList)
        }
    }


    func useTextViewText(request: ToDoScreenFlow.OnTextChanged.Request) {
        guard let cellId = Int(request.id) else { return }

        if let index = taskListFromNetOrDB?.tasks.firstIndex(where: { $0.id == cellId }) {
            taskListFromNetOrDB?.tasks[index].description = request.taskNameText ?? ""
            taskListFromNetOrDB?.tasks[index].subTitle = request.taskSubtitleText
            taskListFromNetOrDB?.tasks[index].timeForToDo = request.timeSubtitleText
        }

        if let changedTaskList = self.taskListFromNetOrDB {
            saveChanged(taskListForSave: changedTaskList)
        }
    }



    // MARK: - Private methods

    private func makeFilteredListFromOriginalBy(filterType: ToDoModel.FilterType) -> TaskList? {
        if let taskList = self.taskListFromNetOrDB {
            var tasksToShow = taskList.tasks

            var openedTasks: [Task] = []
            var closedTasks: [Task] = []

            for task in tasksToShow {
                if task.isCompleted {
                    closedTasks.append(task)
                } else {
                    openedTasks.append(task)
                }
            }

            switch filterType {
            case .all:
                tasksToShow = taskList.tasks
            case .opened:
                tasksToShow = openedTasks
            case .closed:
                tasksToShow = closedTasks
            }

            completedTasksAmount = taskListFromNetOrDB?.tasks.filter { $0.isCompleted }.count
            filteredTasksListForUI = taskListFromNetOrDB
            filteredTasksListForUI?.tasks = tasksToShow
        }
        return filteredTasksListForUI
    }

    private func saveChanged(taskListForSave: TaskList) {
        self.storageWorker.saveToDos(taskListForSave) { saveResult in
            switch saveResult {
            case .success:
                print("Updated data saved to DB successfully.")
            case .failure(let error):
                print("Failed to save data to DB: \(error)")
            }
        }
    }

    private func presenterUpdateUIWith(taskList: TaskList) {
        presenter?.presentToDoList(response: ToDoScreenFlow.Update.Response(taskList: taskList,
                                                                            totalTasks: totalTasks,
                                                                            completedTasksCount: completedTasksAmount,
                                                                            filterType: filterType))
    }

    private func fetchToDosFromDB() {
        self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: true))
        storageWorker.fetchToDosFromDataBase { [weak self] result in
            guard let self = self else { return }
            self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: false))
            switch result {
            case .success(let taskListFromDB):
                self.taskListFromNetOrDB = taskListFromDB
                self.totalTasks = taskListFromDB.tasks.count
                self.completedTasksAmount = taskListFromNetOrDB?.tasks.filter { $0.isCompleted }.count ?? 0
                self.presenter?.presentToDoList(response: ToDoScreenFlow.Update.Response(taskList: taskListFromDB,
                                                                                         totalTasks: totalTasks,
                                                                                         completedTasksCount: completedTasksAmount,
                                                                                         filterType: filterType))
            case .failure(let error):
                print("Failed to load data from DB: \(error)")
                self.loadToDosFromNet()
            }
        }
    }

    private func loadToDosFromNet() {
        self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: true))
        networkWorker.loadToDosFromNetwork { [weak self] result in
            guard let self = self else { return }
            self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: false))
            switch result {
            case .success(let taskList):
                self.taskListFromNetOrDB = taskList
                self.totalTasks = taskList.tasks.count
                self.completedTasksAmount = taskList.tasks.filter { $0.isCompleted }.count
                self.presenter?.presentToDoList(response: ToDoScreenFlow.Update.Response(
                    taskList: taskList,
                    totalTasks: totalTasks,
                    completedTasksCount: completedTasksAmount,
                    filterType: filterType))

                self.storageWorker.saveToDos(taskList) { saveResult in
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
