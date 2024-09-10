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

    func displayUpdate(viewModel: ToDoScreenFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel)
}


final class ToDoViewController: UIViewController, ToDoViewProtocol, NavigationBarControllable, AlertDisplayable {

    // MARK: - Public properties
    var presenter: ToDoPresenterProtocol?
    var menuModel: [ToDoModel] = []
    lazy var contentView: ToDoViewLogic = ToDoScreenView()
//    var modelWithAddedQuantity: [ToDoModel] = []

    // MARK: - Private properties


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
//        interactor?.onDidLoadViews(request: OneEmailDetailsFlow.OnDidLoadViews.Request())
        //        menuModel = presenter?.interactor?.toDoModel ?? []
        //        modelWithAddedQuantity = menuModel
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
    func onChangeTextInTextView(_ viewModel: ToDoCellViewModel, 
                                taskNameText: String, 
                                taskSubtitleText: String,
                                timeSubtitleText: String) {
        presenter?.useTextViewText(request: ToDoScreenFlow.OnTextChanged.Request(
            id: viewModel.id,
            taskNameText: taskNameText,
            taskSubtitleText: taskSubtitleText,
            timeSubtitleText: timeSubtitleText))
    }

    func didTapNewTaskButton() {
        ()
    }

    func didTapTaskCell(_ viewModel: ToDoCellViewModel) {
        ()
    }

    func didTapCheckMark(_ viewModel: ToDoCellViewModel) {
        presenter?.didTapCheckMark(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: viewModel.id))
    }

    func didTapFilterCell(_ viewModel: OneFilterCellViewModel) {
        presenter?.didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request(filterType: viewModel.typeOfFilterCell))
    }

    func didSwipeLeftToDelete(_ viewModel: ToDoCellViewModel) {
        presenter?.didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: viewModel.id))
    }
}
