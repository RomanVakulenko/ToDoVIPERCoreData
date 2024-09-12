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
        let viewController = ToDoViewController()

        let storageManager = StorageDataManager.shared
        let networkManager = NetworkManager(networkService: NetworkService(),
                                            mapper: DataMapper())
        let networkWorker = ToDoNetworkWorker(networkManager: networkManager)

        let storageWorker = StorageWorker(coreDataManager: storageManager)

        let interactor = ToDoInteractor(networkWorker: networkWorker,
                                        storageWorker: storageWorker)
        let presenter = ToDoPresenter()
        let router = ToDoRouter()

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
