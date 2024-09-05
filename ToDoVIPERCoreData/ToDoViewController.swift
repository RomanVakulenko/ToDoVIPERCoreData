//
//  ToDoView.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit
import SnapKit

protocol ToDoViewProtocol: AnyObject {
    var presenter: ToDoPresenterProtocol? { get set }
//    var modelWithAddedQuantity: [ToDoModel] { get set }
}


final class ToDoViewController: UIViewController, ToDoViewProtocol {

    // MARK: - Public properties
    var presenter: ToDoPresenterProtocol?
    var menuModel: [ToDoModel] = []
//    var modelWithAddedQuantity: [ToDoModel] = []

    // MARK: - Private properties


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
        menuModel = presenter?.interactor?.toDoModel ?? []
//        modelWithAddedQuantity = menuModel
    }

    // MARK: - Private methods
    private func setupView() {


    }

    private func layout() {


    }

    // MARK: - Actions

}



// MARK: - UITableViewDataSource
extension ToDoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
    

}

// MARK: - UITableViewDelegate
extension ToDoViewController: UITableViewDelegate {


}


extension ToDoViewController: ToDoViewOutput {
    func didTapNewTaskButton() {
        ()
    }
    
    func didTapTaskCell(_ viewModel: ToDoCellViewModel) {
        ()
    }
    
    func didTapCheckMark(_ viewModel: ToDoCellViewModel) {
        ()
    }
    
    func didTapFilterCell(_ viewModel: OneFilterCellViewModel) {
        ()
    }

}
