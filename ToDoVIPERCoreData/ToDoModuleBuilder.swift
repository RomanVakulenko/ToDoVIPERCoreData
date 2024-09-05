//
//  ToDoModuleBuilder.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit

protocol ToDoModuleBuilderProtocol: AnyObject {
    func getController() -> UIViewController
}

final class ToDoModuleBuilder: ToDoModuleBuilderProtocol {

    func getController() -> UIViewController {
        let view = ToDoViewController()
        let router = ToDoRouter()
        let interactor = ToDoInteractor()
        let presenter = ToDoPresenter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
