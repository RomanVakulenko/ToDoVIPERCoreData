//
//  ToDoRouter.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit

protocol ToDoRoutingLogic: AnyObject {
    func routeToTaskDetailsScreen()
}


final class ToDoRouter: ToDoRoutingLogic {

    // MARK: - Public properties
    weak var viewController: ToDoViewController?
    weak var dataStore: ToDoPresenterDataStore?

    // MARK: - Public methods
    func routeToTaskDetailsScreen() {
        //        if let id = dataStore?.model {
        //                let oneTaskDetailsController = OneTaskDetailsBuilder().getControllerWith(model: model)
        //                let navigationController = UINavigationController(rootViewController: viewController)
        //
        //                DispatchQueue.main.async { [weak self] in
        //                    if let navigationController = self?.viewController?.navigationController {
        //                        navigationController.pushViewController(oneTaskDetailsController, animated: true)
        //                    }
        //                }
        //        }
    }
}
