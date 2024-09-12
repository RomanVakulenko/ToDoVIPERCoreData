//
//  ToDoRouter.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit

protocol ToDoRoutingLogic: AnyObject {
    func routeToOneTaskEditScreen()
}

protocol ToDoScreenDataPassing {
    var dataStore: ToDoInteractorDataStore? { get }
}

final class ToDoRouter: ToDoRoutingLogic, ToDoScreenDataPassing {

    // MARK: - Public properties
    weak var viewController: ToDoViewController?
    weak var dataStore: ToDoInteractorDataStore?

    // MARK: - Public methods
    func routeToOneTaskEditScreen() {
        if let addOrEdit = dataStore?.addOrEdit {
            let oneTaskEditController = EditTaskModuleBuilder().getControllerWith(
                task: dataStore?.selectedTask,
                taskList: dataStore?.taskListFromNetOrDB,
                type: addOrEdit)

            DispatchQueue.main.async { [weak self] in
                if let navigationController = self?.viewController?.navigationController {
                    navigationController.pushViewController(oneTaskEditController, animated: true)
                }
            }
        }
    }

}
