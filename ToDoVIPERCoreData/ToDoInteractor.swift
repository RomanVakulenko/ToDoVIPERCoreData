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

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request)
    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request)
    func onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request)

    func addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request)

    func didTapCheckMarkWith(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)
    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)
}


protocol ToDoInteractorDataStore: AnyObject {
    var selectedTask: OneTask? { get }
    var addOrEdit: EditTaskModel.EditType? { get }
    var taskListFromNetOrDB: TaskList? { get }
}


final class ToDoInteractor: ToDoInteractorProtocol, ToDoInteractorDataStore {

    // MARK: - Public properties
    weak var presenter: ToDoPresenterProtocol?

    var taskListFromNetOrDB: TaskList?
    var filteredTasksListForUI: TaskList?
    var totalTasks = 0
    var completedTasksAmount: Int?

    var selectedTask: OneTask?
    var addOrEdit: EditTaskModel.EditType?

    // MARK: - Private properties
    private let networkWorker: ToDoNetworkWorkerProtocol
    private let storageWorker: StorageWorkerProtocol

    var filterType = ToDoModel.FilterType.all

    // MARK: - Init
    init(networkWorker: ToDoNetworkWorkerProtocol,
         storageWorker: StorageWorkerProtocol) {
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

    func addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request) {
        addOrEdit = .add

        presenter?.presentRouteToAddOrEditTaskScreen(
            response: ToDoScreenFlow.OnSelectItem.Response())
    }

    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request) {
        filterType = request.filterType

        filteredTasksListForUI = makeFilteredListFromOriginalBy(filterType: filterType)

        if let filteredListForUI = self.filteredTasksListForUI {
            presenterUpdateUIWith(taskList: filteredListForUI)
        }
    }


    func onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request) {
        guard let selectedId = Int(request.id ?? "") else { return }
        selectedTask = taskListFromNetOrDB?.tasks.first(where: { $0.id == selectedId })
        addOrEdit = .edit

        //showing edit screen only for not completed tasks or new task
        if let taskToEdit = selectedTask,
           !taskToEdit.isCompleted {
            presenter?.presentRouteToAddOrEditTaskScreen(
                response: ToDoScreenFlow.OnSelectItem.Response())
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


    // MARK: - Private methods

    private func makeFilteredListFromOriginalBy(filterType: ToDoModel.FilterType) -> TaskList? {
        if let taskList = self.taskListFromNetOrDB {
            var tasksToShow = taskList.tasks

            var openedTasks: [OneTask] = []
            var closedTasks: [OneTask] = []

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
        self.storageWorker.saveToDos(taskListForSave) {  [weak self] saveResult in
            guard let self = self else { return }

            switch saveResult {
            case .success:
                print("Updated data saved to DB successfully.")
            case .failure(let error):
                presenter?.presentAlert(response: ToDoScreenFlow.AlertInfo.Response(error: error))
                print("Failed to save data to DB: \(error)")
            }
        }
    }

    private func presenterUpdateUIWith(taskList: TaskList) {
        presenter?.presentToDoList(response: ToDoScreenFlow.Update.Response(
            taskList: taskList,
            totalTasks: totalTasks,
            completedTasksCount: completedTasksAmount,
            filterType: filterType))
    }

    private func fetchToDosFromDB() {
        self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: true))
        storageWorker.fetchToDosFromDataBase { [weak self] result in
            guard let self = self else { return }
            self.presenter?.presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response(isShow: false)
            )
            switch result {
            case .success(let taskListFromDB):
                self.taskListFromNetOrDB = taskListFromDB
                self.totalTasks = taskListFromDB.tasks.count
                self.completedTasksAmount = taskListFromNetOrDB?.tasks.filter { $0.isCompleted }.count ?? 0

                self.presenter?.presentToDoList(response: ToDoScreenFlow.Update.Response(
                    taskList: taskListFromDB,
                    totalTasks: totalTasks,
                    completedTasksCount: completedTasksAmount,
                    filterType: filterType))

            case .failure(let error):
                print("Failed to load data from DB: \(error)")
                presenter?.presentAlert(response: ToDoScreenFlow.AlertInfo.Response(error: error))
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

                self.storageWorker.saveToDos(taskList) { [weak self] saveResult in
                    guard let self = self else { return }
                    switch saveResult {
                    case .success:
                        print("Data saved to DB successfully.")
                    case .failure(let error):
                        presenter?.presentAlert(response: ToDoScreenFlow.AlertInfo.Response(error: error))
                        print("Failed to save data to DB: \(error)")
                    }
                }
            case .failure(let error):
                presenter?.presentAlert(response: ToDoScreenFlow.AlertInfo.Response(error: error))
                print("Failed to load data from network: \(error)")
            }
        }
    }

}
