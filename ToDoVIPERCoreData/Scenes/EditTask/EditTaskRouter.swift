//
//  EditTaskRouter.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import UIKit

protocol EditTaskRoutingLogic: AnyObject {
    func routeBack()
}


final class EditTaskRouter: EditTaskRoutingLogic {

    // MARK: - Public properties
    weak var viewController: EditTaskViewController?
    weak var dataStore: EditTaskInteractorDataStore?

    // MARK: - Public methods
    func routeBack() {
        if let viewController = viewController {

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                viewController.navigationController?.popViewController(animated: true)
            }
        }
    }
}
