//
//  EditTaskView.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import UIKit
import SnapKit

protocol EditTaskViewProtocol: AnyObject {
    var presenter: EditTaskPresenterProtocol? { get set }

    func displayUpdate(viewModel: EditTaskScreenFlow.Update.ViewModel)
    func displayWaitIndicator(viewModel: EditTaskScreenFlow.OnWaitIndicator.ViewModel)
    func displayAlert(viewModel: EditTaskScreenFlow.AlertInfo.ViewModel)
}


final class EditTaskViewController: UIViewController, EditTaskViewProtocol, NavigationBarControllable, AlertDisplayable {

    // MARK: - Public properties
    var presenter: EditTaskPresenterProtocol?
    lazy var contentView: EditTaskViewLogic = EditTaskScreenView()

    // MARK: - Lifecycle
    override func loadView() {
        contentView.output = self
        view = contentView
        hideNavigationBar(animated: false) //to hide flashing blue "< Back"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        presenter?.showTaskForm(request: EditTaskScreenFlow.OnDidLoadViews.Request())
    }

    func leftNavBarButtonDidTapped() {
        self.navigationController?.popViewController(animated: true)
    }

    func rightNavBarButtonTapped(index: Int) {
       ()
    }

    func displayUpdate(viewModel: EditTaskScreenFlow.Update.ViewModel) {
        configureNavigationBar(navBar: viewModel.navBar)
        showNavigationBar(animated: false)

        contentView.update(viewModel: viewModel)
    }

    func displayWaitIndicator(viewModel: EditTaskScreenFlow.OnWaitIndicator.ViewModel) {
        contentView.displayWaitIndicator(viewModel: viewModel)
    }


    func displayAlert(viewModel: EditTaskScreenFlow.AlertInfo.ViewModel) {
        if viewModel.text == "Заполни описание!" {
            showAlert(title: viewModel.title,
                      message: viewModel.text,
                      firstButtonTitle: viewModel.firstButtonTitle)
        } else {
            showAlert(title: viewModel.title,
                      message: viewModel.text,
                      firstButtonTitle: viewModel.firstButtonTitle,
                      firstButtonCompletion: {
                self.presenter?.presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response())
            })
        }
    }


    // MARK: - Private methods
    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() { }
    private func configureConstraints() { }
}


// MARK: - EditTaskViewOutput
extension EditTaskViewController: EditTaskViewOutput {
    
    func onChangeTextInTextView(_ viewModel: ToDoCellViewModel,
                                taskNameText: String,
                                taskSubtitleText: String,
                                timeSubtitleText: String) {
        presenter?.useTextViewText(request: EditTaskScreenFlow.OnTextChanged.Request(
            id: Int(viewModel.id) ?? 0,
            taskNameText: taskNameText,
            taskSubtitleText: taskSubtitleText,
            timeSubtitleText: timeSubtitleText))
    }

    func didTapSaveButton() {
        presenter?.didTapSaveButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request())
    }

    func didTapDeleteButton() {
        presenter?.didTapDeleteButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request())
    }

}
