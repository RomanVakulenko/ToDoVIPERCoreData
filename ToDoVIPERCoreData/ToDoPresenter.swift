//
//  ToDoPresenter.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import Foundation

typealias ToDoPresentable = ToDoPresenterProtocol //& ToDoPresenterDataStore

protocol ToDoPresenterProtocol: AnyObject {
    var view: ToDoViewProtocol? { get set }
    var interactor: ToDoInteractorProtocol? { get set }
    var router: ToDoRoutingLogic? { get set }

    func makeTransitionWith(model: [ToDoModel])
}

protocol ToDoPresenterDataStore: AnyObject {
//    var model: [ToDoModel] { get }
}


// MARK: - ToDoPresenter
final class ToDoPresenter: ToDoPresentable {

    weak var view: ToDoViewProtocol?
    var interactor: ToDoInteractorProtocol?
    var router: ToDoRoutingLogic?
//    var model: [ToDoModel] = []


    func makeTransitionWith(model: [ToDoModel]) {
        router?.routeToTaskDetailsScreen()
    }
}
