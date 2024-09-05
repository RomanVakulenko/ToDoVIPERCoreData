//
//  ToDoInteractor.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import Foundation


protocol ToDoInteractorProtocol: AnyObject {
    var presenter: ToDoPresenterProtocol? { get set }
    var toDoModel: [ToDoModel] { get set }
}


final class ToDoInteractor: ToDoInteractorProtocol {

    weak var presenter: ToDoPresenterProtocol?
    var toDoModel: [ToDoModel] = []

}
