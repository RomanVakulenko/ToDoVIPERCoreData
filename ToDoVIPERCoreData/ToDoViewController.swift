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

    func displayUpdate(viewModel: ToDoScreenFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel)
}


final class ToDoViewController: UIViewController, ToDoViewProtocol, NavigationBarControllable, AlertDisplayable {

    // MARK: - Public properties
    var presenter: ToDoPresenterProtocol?
    lazy var contentView: ToDoViewLogic = ToDoScreenView()

    // MARK: - Lifecycle
    override func loadView() {
        contentView.output = self
        view = contentView
        hideNavigationBar(animated: false) //to hide flashing blue "< Back"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        presenter?.getData(request: ToDoScreenFlow.OnDidLoadViews.Request())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.getData(request: ToDoScreenFlow.OnDidLoadViews.Request())
    }

    func leftNavBarButtonDidTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    func rightNavBarButtonTapped(index: Int) {
       ()
    }

    func displayUpdate(viewModel: ToDoScreenFlow.Update.ViewModel) {
//        configureNavigationBar(navBar: viewModel.navBar)
        showNavigationBar(animated: false)

        contentView.update(viewModel: viewModel)
    }

    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }


    // MARK: - Private methods
    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() { }
    private func configureConstraints() { }
}


// MARK: - ToDoViewOutput
extension ToDoViewController: ToDoViewOutput {

    func didTapNewTaskButton() {
        presenter?.addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request())
    }

    func didTapFilterCell(_ viewModel: OneFilterCellViewModel) {
        presenter?.didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request(filterType: viewModel.typeOfFilterCell))
    }

    func didTapCell(_ viewModel: ToDoCellViewModel) {
        presenter?.onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request(id: viewModel.id))
    }

    func didTapCheckMark(_ viewModel: ToDoCellViewModel) {
        presenter?.didTapCheckMark(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: viewModel.id))
    }

    func didSwipeLeftToDelete(_ viewModel: ToDoCellViewModel) {
        presenter?.didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: viewModel.id))
    }
}
