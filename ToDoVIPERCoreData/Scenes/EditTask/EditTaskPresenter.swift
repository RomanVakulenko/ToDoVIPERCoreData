//
//  EditTaskPresenter.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import Foundation
import DifferenceKit

typealias EditTaskPresentable = EditTaskPresenterProtocol

protocol EditTaskPresenterProtocol: AnyObject {
    var viewController: EditTaskViewProtocol? { get set }
    var interactor: EditTaskInteractorProtocol? { get set }
    var router: EditTaskRoutingLogic? { get set }

    func presentWaitIndicator(response: EditTaskScreenFlow.OnWaitIndicator.Response)

    func showTaskForm(request: EditTaskScreenFlow.OnDidLoadViews.Request)
    func useTextViewText(request: EditTaskScreenFlow.OnTextChanged.Request)
    func didTapSaveButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request)
    func didTapDeleteButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request)
    func presentUpdate(response: EditTaskScreenFlow.Update.Response)

    func presentAlert(response: EditTaskScreenFlow.AlertInfo.Response)

    func presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response)
}

// MARK: - EditTaskPresenter
final class EditTaskPresenter: EditTaskPresentable {

    weak var viewController: EditTaskViewProtocol?
    var interactor: EditTaskInteractorProtocol?
    var router: EditTaskRoutingLogic?

    // MARK: - Public methods

    func showTaskForm(request: EditTaskScreenFlow.OnDidLoadViews.Request) {
        interactor?.showTaskForm(request: request)
    }

    func didTapSaveButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request) {
        interactor?.didTapSaveButton(request: request)
    }

    func didTapDeleteButton(request: EditTaskScreenFlow.OnSaveOrDeleteTap.Request) {
        interactor?.didTapDeleteButton(request: request)
    }

    func useTextViewText(request: EditTaskScreenFlow.OnTextChanged.Request) {
        interactor?.useTextViewText(request: request)
    }



    func presentUpdate(response: EditTaskScreenFlow.Update.Response) {

        let backViewColor = UIHelper.Color.grayBack
        let separatorColor = UIHelper.Color.lightGrayTimeAndSeparator

        var textForScreenTitle = "Create new task"
        if response.type  == .edit {
            textForScreenTitle = "Edit task or delete"
        }

        let screenTitle = NSMutableAttributedString(
            string: textForScreenTitle,
            attributes: UIHelper.Attributed.blackInterBold22)

        let navBar = CustomNavBar(title: screenTitle,
                                  isLeftBarButtonEnable: true,
                                  isLeftBarButtonCustom: false,
                                  leftBarButtonCustom: nil,
                                  rightBarButtons: [])

        var tableItems: [AnyDifferentiable] = []



        tableItems.append(makeOneTaskCell(task: response.task,
                                          type: response.type,
                                          totalTasks: response.totalTasks))

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.displayUpdate(viewModel: EditTaskScreenFlow.Update.ViewModel(
                backViewColor: backViewColor,
                navBarBackground: backViewColor,
                navBar: navBar,
                separatorColor: separatorColor,
                saveButtonTitle: makeButton(title: "Save"),
                saveButtonBackColor: UIHelper.Color.systemBlue,
                deleteButtonTitle: makeButton(title: "Delete"),
                deleteButtonBackColor: UIHelper.Color.red,
                items: tableItems))
        }

    }

    func presentWaitIndicator(response: EditTaskScreenFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: EditTaskScreenFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }

    func presentRouteBack(response: ToDoScreenFlow.OnSelectItem.Response) {
        router?.routeBack()
    }


    func presentAlert(response: EditTaskScreenFlow.AlertInfo.Response) {
        var title = "Error"
        var text = ""
        
        switch response.alertAt {
        case .savedSuccessfully:
            title = "Уведомление"
            text = "Сохранена успешно"
        case .deletedSuccessfully:
            title = "Уведомление"
            text = "Удалена успешно"
        case .fillNeededFields:
            text = "Заполни описание!"
        default: break
        }

        let buttonTitle = "Ok"

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayAlert(
                viewModel: EditTaskScreenFlow.AlertInfo.ViewModel(
                    title: title,
                    text: text,
                    firstButtonTitle: buttonTitle))
        }
    }


    // MARK: - Private methods

    private func makeButton(title: String) -> NSAttributedString {
        NSAttributedString(string: title,
                           attributes: UIHelper.Attributed.whiteInterBold18)
    }


    private func makeOneTaskCell(task: OneTask?,
                                 type: EditTaskModel.EditType,
                                 totalTasks: Int) -> AnyDifferentiable {

        var textForDescription = "введи"
        var textForSubtitle = "введи"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedTimeToString = dateFormatter.string(from: Date())

        var textForTimeOfDoing = formattedTimeToString
        if type == .edit {
            textForDescription = task?.description ?? ""
            textForSubtitle = task?.subTitle ?? ""
        }

        let taskNameText = NSAttributedString(string: textForDescription,
                                              attributes: UIHelper.Attributed.systemBlueInterBold18Black)

        let separatorColor = UIHelper.Color.lightGrayTimeAndSeparator

        let taskSubtitle = NSAttributedString(string: textForSubtitle,
                                              attributes: UIHelper.Attributed.grayInterMedium16)
        var id = "0"
        if let task = task {
            id = String(task.id)
        } else {
            id = String(totalTasks + 1)
        }

        let oneTaskCell = ToDoCellViewModel(id: id,
                                            backColor:  UIColor.white,
                                            taskNameText: taskNameText,
                                            taskSubtitleText: taskSubtitle,
                                            checkMarkImage: nil,
                                            separatorColor: separatorColor,
                                            todaySubtitle: "Время для выполнения: ",
                                            timeSubtitle: textForTimeOfDoing,
                                            insets: UIEdgeInsets(top: 0,
                                                                 left: 0,
                                                                 bottom: 0,
                                                                 right: 0), 
                                            isEditMode: true)

        return AnyDifferentiable(oneTaskCell)
    }

}
