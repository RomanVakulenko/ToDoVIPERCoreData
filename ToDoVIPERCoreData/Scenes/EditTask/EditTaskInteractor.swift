//
//  EditTaskInteractor.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import Foundation
import CoreData


protocol EditTaskInteractorProtocol: AnyObject {
    var presenter: EditTaskPresenterProtocol? { get set }

    func showTaskForm(request: EditTaskScreenFlow.OnDidLoadViews.Request)

    func didTapSaveButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request)
    func didTapDeleteButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request)

    func useTextViewText(request: EditTaskScreenFlow.OnTextChanged.Request)
}


protocol EditTaskInteractorDataStore: AnyObject {
//    var taskList: TaskList? { get }
}


final class EditTaskInteractor: EditTaskInteractorProtocol, EditTaskInteractorDataStore {

    // MARK: - Public properties
    weak var presenter: EditTaskPresenterProtocol?

    // MARK: - Private properties
    private let storageWorker: StorageWorkerProtocol
    private var taskListFromNetOrDB: TaskList?
    private var totalTasks: Int {
        return taskListFromNetOrDB?.tasks.count ?? 0
    }
    private var task: OneTask?
    private var addOrEditType: EditTaskModel.EditType

    private var id = Int()
    private var taskNameText = ""
    private var taskSubtitleText = ""
    private var timeSubtitleText = ""

    // MARK: - Init
    init(storageWorker: StorageWorkerProtocol,
         taskList: TaskList?,
         task: OneTask?,
         type: EditTaskModel.EditType) {
        self.storageWorker = storageWorker
        self.taskListFromNetOrDB = taskList
        self.task = task
        self.addOrEditType = type
    }

    // MARK: - Public methods

    func showTaskForm(request: EditTaskScreenFlow.OnDidLoadViews.Request) {
        presenter?.presentUpdate(response: EditTaskScreenFlow.Update.Response(
            totalTasks: totalTasks,
            task: task,
            type: addOrEditType))
    }

    func didTapSaveButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request) {

        let newTask = OneTask(from: DTOTask(
            id: id,
            todo: taskNameText,
            subTitle: taskSubtitleText,
            timeForToDo: timeSubtitleText,
            completed: false,
            userId: Int.random(in: 1...1000)))

        if addOrEditType == .add,
           !newTask.description.isEmpty {
            taskListFromNetOrDB?.tasks.append(newTask)
            print("taskToSave - \(newTask)")

            if let changedTaskList = self.taskListFromNetOrDB {
                saveChanged(taskListForSave: changedTaskList)
            }
            presenter?.presentAlert(response: EditTaskScreenFlow.AlertInfo.Response(
                error: nil,
                alertAt: .savedSuccessfully))
            presenter?.presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response())

        } else if addOrEditType == .edit {
            if let index = taskListFromNetOrDB?.tasks.firstIndex(where: { $0.id == task?.id }) {
                taskListFromNetOrDB?.tasks[index].description = taskNameText
                taskListFromNetOrDB?.tasks[index].subTitle = taskSubtitleText
                taskListFromNetOrDB?.tasks[index].timeForToDo = timeSubtitleText
                print("subTitle -  \(String(describing: taskListFromNetOrDB?.tasks[index]))")

                if let changedTaskList = self.taskListFromNetOrDB {
                    saveChanged(taskListForSave: changedTaskList)
                }
                presenter?.presentAlert(response: EditTaskScreenFlow.AlertInfo.Response(
                    error: nil,
                    alertAt: .savedSuccessfully))
                presenter?.presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response())
            }
        } else {
            presenter?.presentAlert(response: EditTaskScreenFlow.AlertInfo.Response(
                error: nil,
                alertAt: .fillNeededFields))
        }
    }


    func didTapDeleteButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request) {
        if let taskToDelete = task {
            self.taskListFromNetOrDB?.tasks.removeAll(where: { $0.id == taskToDelete.id })

            if let changedTaskList = self.taskListFromNetOrDB {
                saveChanged(taskListForSave: changedTaskList)
            }
            presenter?.presentAlert(response: EditTaskScreenFlow.AlertInfo.Response(
                error: nil,
                alertAt: .deletedSuccessfully))
            presenter?.presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response())
        }
    }


    func useTextViewText(request: EditTaskScreenFlow.OnTextChanged.Request) {
        id = request.id
        taskNameText = request.taskNameText
        taskSubtitleText = request.taskSubtitleText
        timeSubtitleText = request.timeSubtitleText
    }



    // MARK: - Private methods

    private func saveChanged(taskListForSave: TaskList) {
        self.storageWorker.saveToDos(taskListForSave) { [weak self] saveResult in
            guard let self = self else { return }

            switch saveResult {
            case .success:
                print("Updated data saved to DB successfully.")
            case .failure(let error):
                print("Failed to save data to DB: \(error)")
                self.presenter?.presentAlert(response: EditTaskScreenFlow.AlertInfo.Response(
                    error: .errorAtSaving,
                    alertAt: nil))
            }
        }
    }

}
