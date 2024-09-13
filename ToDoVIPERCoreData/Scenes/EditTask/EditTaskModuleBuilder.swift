//
//  EditTaskModuleBuilder.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import UIKit

protocol EditTaskModuleBuilderProtocol: AnyObject {
    func getControllerWith(task: OneTask?,
                           taskList: TaskList?,
                           type: EditTaskModel.EditType) -> UIViewController
}

final class EditTaskModuleBuilder: EditTaskModuleBuilderProtocol {

    func getControllerWith(task: OneTask?,
                           taskList: TaskList?,
                           type: EditTaskModel.EditType) -> UIViewController {
        let viewController = EditTaskViewController()

        let storageManager = StorageDataManager.shared
        let storageWorker = StorageWorker(coreDataManager: storageManager)
        let interactor = EditTaskInteractor(storageWorker: storageWorker,
                                            taskList: taskList,
                                            task: task,
                                            type: type)

        let presenter = EditTaskPresenter()
        let router = EditTaskRouter()
        viewController.presenter = presenter

        presenter.viewController = viewController
        presenter.interactor = interactor
        presenter.router = router

        interactor.presenter = presenter

        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}
