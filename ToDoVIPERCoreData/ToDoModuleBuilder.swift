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

        let storageManager = StorageDataManager.shared
        let networkManager = NetworkManager(networkService: NetworkService(),
                                            mapper: DataMapper())
        let networkWorker = ToDoNetworkWorker(networkManager: networkManager)

        let storageWorker = ToDoStorageWorker(coreDataManager: storageManager)

        let interactor = ToDoInteractor(networkWorker: networkWorker,
                                        storageWorker: storageWorker)
        let presenter = ToDoPresenter()
        let router = ToDoRouter()


        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return view
    }
}
