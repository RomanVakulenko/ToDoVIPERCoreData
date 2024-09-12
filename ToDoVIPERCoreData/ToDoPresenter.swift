//
//  ToDoPresenter.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import Foundation
import DifferenceKit

typealias ToDoPresentable = ToDoPresenterProtocol

protocol ToDoPresenterProtocol: AnyObject {
    var viewController: ToDoViewProtocol? { get set }
    var interactor: ToDoInteractorProtocol? { get set }
    var router: ToDoRoutingLogic? { get set }

    func presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response)
    func presentToDoList(response: ToDoScreenFlow.Update.Response)

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request)

    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request)
    func didTapCheckMark(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)
    func onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request)

    func addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request)

    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request)
    func presentRouteToAddOrEditTaskScreen(response: ToDoScreenFlow.OnSelectItem.Response)
}

// MARK: - ToDoPresenter
final class ToDoPresenter: ToDoPresentable {

    weak var viewController: ToDoViewProtocol?
    var interactor: ToDoInteractorProtocol?
    var router: ToDoRoutingLogic?

   private var focusedTextViewIndexPath: IndexPath?
   private var cursorPosition: Int?

    // MARK: - Public methods

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request) {
        interactor?.getData(request: request)
    }

    func addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request) {
        interactor?.addNewTask(request: request)
    }

    func didTapCheckMark(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {
        interactor?.didTapCheckMarkWith(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: request.id))
    }

    func onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request) {
        interactor?.onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request(id: request.id))
    }

    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {
        interactor?.didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: request.id))
    }

    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request) {
        interactor?.didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request(filterType: request.filterType))
    }

    func presentRouteToAddOrEditTaskScreen(response: ToDoScreenFlow.OnSelectItem.Response) {
        router?.routeToOneTaskEditScreen()
    }


    func presentToDoList(response: ToDoScreenFlow.Update.Response) {
        let taskList = response.taskList
        print(response.taskList.tasks)

        let backViewColor = UIHelper.Color.grayBack

        let total = response.totalTasks
        let completed = response.completedTasksCount
        let opened = total - (completed ?? 0)

        var views: [AnyDifferentiable] = []

        views.append(makeFilterView(all: total,
                                    opened: opened,
                                    closed: completed ?? 0,
                                    selectedFilter: response.filterType))


        let group = DispatchGroup()
        var lock = os_unfair_lock_s()

        var tableItems: [AnyDifferentiable] = []
        var dictTasks: Dictionary<Int,ToDoCellViewModel> = [:]

        let sortedTasks = taskList.tasks.sorted { $0.id < $1.id }

        for (index, task) in sortedTasks.enumerated() {
            group.enter()

            makeOneTaskCell(task: task) { (toDoCellViewModel, id) in
                os_unfair_lock_lock(&lock)
                dictTasks[id] = toDoCellViewModel //чтобы одновременного обращения к словарю не было
                os_unfair_lock_unlock(&lock)
                group.leave()
            }
        }

        group.notify(queue: DispatchQueue.global()) {[weak self] in
            guard let self = self else { return }

            let sortedDictKeys = Array(dictTasks.keys).sorted()
            for key in sortedDictKeys {
                if let taskCellVM = dictTasks[key] {
                    tableItems.append(AnyDifferentiable(taskCellVM))
                }
            }

            let screenTitle = NSAttributedString(
                string: "Today's Task",
                attributes: UIHelper.Attributed.blackInterBold22)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, d MMMM"
            let formattedDateToString = dateFormatter.string(from: Date())

            let subtitle = NSAttributedString(
                string: formattedDateToString,
                attributes: UIHelper.Attributed.grayInterMedium16)


            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.viewController?.displayUpdate(viewModel: ToDoScreenFlow.Update.ViewModel(
                    screenTitle: screenTitle,
                    subtitle: subtitle,
                    backViewColor: backViewColor,
                    newTaskButtonTitle: makeAddNewTaskButton(),
                    newTaskButtonBackColor: UIHelper.Color.blueButton,
                    views: views,
                    items: tableItems))
            }
        }
    }

    func presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel(isShow: response.isShow))
        }
    }


    // MARK: - Private methods

    private func makeAddNewTaskButton() -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        if let plusImage = UIImage(systemName: "plus")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal) {
            attachment.image = plusImage
        }

        attachment.bounds = CGRect(x: 0,
                                   y: -UIHelper.Margins.small2px,
                                   width: UIHelper.Margins.medium16px,
                                   height: UIHelper.Margins.medium16px)

        let attachmentStringReply = NSAttributedString(attachment: attachment)
        let newTaskButtonMutableAttributedString = NSMutableAttributedString(
            string: " New Task",
            attributes: UIHelper.Attributed.systemBlueInterBold18)

        newTaskButtonMutableAttributedString.insert(attachmentStringReply, at: 0)

        return newTaskButtonMutableAttributedString
    }


    private func makeOneTaskCell(task: OneTask,
                                 completion: @escaping (ToDoCellViewModel, Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var checkMarkImage = UIImage()
            var taskNameText = NSAttributedString()

            if task.isCompleted {
                checkMarkImage = UIImage.init(systemName: "checkmark.circle.fill") ?? UIImage()
                taskNameText = NSAttributedString(string: task.description,
                                                  attributes: UIHelper.Attributed.systemBlueInterBold18StrikedBlack)
            } else {
                checkMarkImage = UIImage(systemName: "circle") ?? UIImage()
                taskNameText = NSAttributedString(string: task.description,
                                                  attributes: UIHelper.Attributed.systemBlueInterBold18Black)
            }

            let separatorColor = UIHelper.Color.lightGrayTimeAndSeparator

            let taskSubtitle = NSAttributedString(
                string: task.subTitle ?? "Task subtitle",
                attributes: UIHelper.Attributed.grayInterMedium16)
            let oneTaskCell = ToDoCellViewModel(id: String(task.id),
                                                backColor:  UIColor.white,
                                                taskNameText: taskNameText,
                                                taskSubtitleText: taskSubtitle,
                                                checkMarkImage: checkMarkImage,
                                                separatorColor: separatorColor,
                                                todaySubtitle: "Время для выполнения: ",
                                                timeSubtitle: task.timeForToDo ?? "введи",
                                                insets: UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0), 
                                                isEditMode: false)

            completion(oneTaskCell, task.id)
        }
    }


    private func makeFilterView(all: Int,
                                opened: Int,
                                closed: Int,
                                selectedFilter: ToDoModel.FilterType) -> AnyDifferentiable {

        let filterTitles: [String] = ["All", "Opened", "Closed"]
        var isFilterSelected: [Bool] = [false, false, false]
        
        switch selectedFilter {
           case .all:
               isFilterSelected[0] = true
           case .opened:
               isFilterSelected[1] = true
           case .closed:
               isFilterSelected[2] = true
        }

        var filterItems: [AnyDifferentiable] = []
        var widthsOfFilterCells = [CGFloat]()

        for (id, title) in filterTitles.enumerated() {
            let isSelected = isFilterSelected[id]
            let oneFilterTitleColor = isSelected ? UIColor.systemBlue : UIHelper.Color.graySubtitleAndFilterButtons
            let filterCounterBackColor = isSelected ? UIColor.systemBlue : UIHelper.Color.graySubtitleAndFilterButtons

            let filterCounterText: String
            var typeOfFilterCell = ToDoModel.FilterType.all

            switch id {
            case 0: 
                filterCounterText = String(all)
            case 1: 
                filterCounterText = String(opened)
                typeOfFilterCell = .opened
            case 2:
                filterCounterText = String(closed)
                typeOfFilterCell = .closed
            default: filterCounterText = ""
            }

            let (filterVM, width) = makeOneFilterCell(id: id,
                                                      typeOfFilterCell: typeOfFilterCell,
                                                      oneFilterTitle: title,
                                                      oneFilterTitleColor: oneFilterTitleColor,
                                                      filterCounterBackColor: filterCounterBackColor,
                                                      filterCounterText: filterCounterText)
            widthsOfFilterCells.append(width)
            filterItems.append(filterVM)
        }

        let separatorCell = AnyDifferentiable(SeparatorCellViewModel(id: "11",
                                                                     separatorColor:  UIHelper.Color.graySubtitleAndFilterButtons,
                                                                     separatorBorderWidth: CGFloat(1),
                                                                     insets: UIEdgeInsets(top: 8, left: 0, bottom: 4, right: 0)))
        let separatorWidth: CGFloat = 1
        filterItems.insert(separatorCell, at: 1)
        widthsOfFilterCells.insert(separatorWidth, at: 1)

        let filterView = CollectionFilterViewModel(id: "1",
                                                   backColor: UIHelper.Color.grayBack,
                                                   insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                   items: filterItems,
                                                   widths: widthsOfFilterCells)
        return (AnyDifferentiable(filterView))
    }

    private func makeOneFilterCell(id: Int,
                                   typeOfFilterCell: ToDoModel.FilterType,
                                   oneFilterTitle: String,
                                   oneFilterTitleColor: UIColor,
                                   filterCounterBackColor: UIColor,
                                   filterCounterText: String) -> (AnyDifferentiable, CGFloat)  {

        var oneFilterWidht = CGFloat()
        let textLenght = CGFloat(oneFilterTitle.size().width) + CGFloat(filterCounterText.size().width) + 6
        oneFilterWidht = UIHelper.Margins.large20px + textLenght + UIHelper.Margins.large20px

        let oneFilterVM = OneFilterCellViewModel(
            id: String(id),
            typeOfFilterCell: typeOfFilterCell,
            oneFilterTitle: oneFilterTitle,
            oneFilterTitleColor: oneFilterTitleColor,
            filterCounterBackColor: filterCounterBackColor,
            filterCounterText: filterCounterText,
            insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))

        return (AnyDifferentiable(oneFilterVM), oneFilterWidht)
    }

}
