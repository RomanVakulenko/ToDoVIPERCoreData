//
//  ToDoPresenter.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import Foundation
import DifferenceKit

typealias ToDoPresentable = ToDoPresenterProtocol //& ToDoPresenterDataStore

protocol ToDoPresenterProtocol: AnyObject {
    var view: ToDoViewProtocol? { get set }
    var interactor: ToDoInteractorProtocol? { get set }
    var router: ToDoRoutingLogic? { get set }

    func changeTextInTaskFieldsAt(request: ToDoScreenFlow.OnTextChanged.Request)
    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request)
    func presentToDoList(response: ToDoScreenFlow.OnDidLoadViews.Response)
    func makeTransitionWith(model: DTOTask)
}

protocol ToDoPresenterDataStore: AnyObject {
    var taskList: TaskList? { get }
}

// MARK: - ToDoPresenter
final class ToDoPresenter: ToDoPresentable {

    weak var view: ToDoViewProtocol?
    var interactor: ToDoInteractorProtocol?
    var router: ToDoRoutingLogic?
    var taskList: TaskList?

    var taskNameText: String?
    var taskSubtitleText = "Subtitle"
    var timeSubtitleText: String?

    private var filterTapped = ToDoModel.FilterType.all

    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request) {
        interactor?.getData(request: request)
    }

    func makeTransitionWith(model: DTOTask) {
        router?.routeToOneTaskDetailsScreen()
    }

    func changeTextInTaskFieldsAt(request: ToDoScreenFlow.OnTextChanged.Request) {
        guard let cellId = Int(request.cellId) else { return }

        if let index = taskList?.tasks.firstIndex(where: { $0.id == cellId }) {
            taskList?.tasks[index].description = request.taskNameText ?? ""
            taskNameText = request.taskNameText ?? ""
        }
        taskSubtitleText = request.taskSubtitleText ?? ""
        timeSubtitleText = request.timeSubtitleText
    }

    func presentToDoList(response: ToDoScreenFlow.OnDidLoadViews.Response) {
        taskList = response.taskList
        print("Loaded tasks: \(taskList)")

        let backViewColor = UIHelper.Color.grayBack

        let total = response.taskList.tasks.count
        let completed = response.taskList.tasks.filter { $0.isCompleted }.count
        let opened = total - completed

        var views: [AnyDifferentiable] = []

        views.append(makeFilterView(all: total,
                                    opened: opened,
                                    closed: completed,
                                    selectedFilter: filterTapped))


        var dictTasks: Dictionary<Int,ToDoCellViewModel> = [:]
        var tableItems: [AnyDifferentiable] = []

        let group = DispatchGroup()
        var lock = os_unfair_lock_s()
        
        for (index, task) in response.taskList.tasks.enumerated() {
            group.enter()
            makeOneTaskCell(task: task,
                            index: task.id) { (toDoCellViewModel, index) in
                os_unfair_lock_lock(&lock)
                dictTasks[index] = toDoCellViewModel //чтобы одновременного обращения к словарю не было
                os_unfair_lock_unlock(&lock)
                group.leave()
            }

        }

        group.notify(queue: DispatchQueue.global()) {[weak self] in
            guard let self = self else { return }

            for index in 0..<dictTasks.count {
                if let taskCellVM = dictTasks[index] {
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
                self.view?.displayUpdate(viewModel: ToDoScreenFlow.Update.ViewModel(
                    screenTitle: screenTitle,
                    subtitle: subtitle,
                    backViewColor: backViewColor,
                    newTaskButtonTitle: makeAddNewTaskButton(),
                    newTaskButtonBackColor: UIHelper.Color.blueBackNewTask,
                    views: views,
                    items: tableItems))
            }
        }
    }

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


    private func makeOneTaskCell(task: Task,
                                 index: Int,
                                 completion: @escaping (ToDoCellViewModel, Int) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            var checkMarkImage = UIImage()
            if task.isCompleted {
                checkMarkImage = UIImage.init(systemName: "checkmark.circle.fill") ?? UIImage()
            } else {
                checkMarkImage = UIImage.init(systemName: "circle") ?? UIImage()
            }

            let separatorColor = UIHelper.Color.lightGrayTimeAndSeparator
            let taskSubtitle = NSAttributedString(
                string: "Task subtitle",
                attributes: UIHelper.Attributed.grayInterMedium16)
            let oneTaskCell = ToDoCellViewModel(id: String(task.id),
                                                backColor:  UIColor.white,
                                                taskNameText: task.description,
                                                taskSubtitleText: taskSubtitle,
                                                checkMarkImage: checkMarkImage,
                                                separatorColor: separatorColor,
                                                todaySubtitle: "Время выполнения: ",
                                                timeSubtitle: timeSubtitleText ?? "",
                                                insets: UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0))

            completion(oneTaskCell, index)
        }
    }


    private func makeFilterView(all: Int,
                                opened: Int,
                                closed: Int,
                                selectedFilter: ToDoModel.FilterType) -> AnyDifferentiable {

        let filterTitles: [String] = ["All", "Open", "Closed"]
        var isFilterSelected: [Bool] = [false, false, false] // Массив для отслеживания выбранных фильтров

        switch selectedFilter {
        case .all:
            isFilterSelected = [true, false, false]
        case .opened:
            isFilterSelected = [false, true, false]
        case .closed:
            isFilterSelected = [false, false, true]
        }

        var filterItems: [AnyDifferentiable] = []
        var widthsOfFilterCells = [CGFloat]()

        for (id, title) in filterTitles.enumerated() {
            let oneFilterTitleColor = isFilterSelected[id] ? UIColor.systemBlue : UIHelper.Color.graySubtitleAndFilterButtons
            let filterCounterBackColor = isFilterSelected[id] ? UIColor.systemBlue : UIHelper.Color.graySubtitleAndFilterButtons

            let filterCounterText = id == 0 ? String(all) : id == 1 ? String(opened) : String(closed)

            let oneFilter = makeFilterVM(id: id,
                                         oneFilterTitle: title,
                                         oneFilterTitleColor: oneFilterTitleColor,
                                         filterCounterBackColor: filterCounterBackColor,
                                         filterCounterText: filterCounterText)

            widthsOfFilterCells.append(oneFilter.1)
            filterItems.append(oneFilter.0)
        }

        let separatorCell = AnyDifferentiable(SeparatorCellViewModel(id: "11",
                                                                     separatorColor:  UIHelper.Color.lightGrayTimeAndSeparator,
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

    private func makeFilterVM(id: Int,
                              oneFilterTitle: String,
                              oneFilterTitleColor: UIColor,
                              filterCounterBackColor: UIColor,
                              filterCounterText: String) -> (AnyDifferentiable, CGFloat)  {

        var oneFilterWidht = CGFloat()
        let textLenght = CGFloat(oneFilterTitle.size().width) + CGFloat(filterCounterText.size().width)
        oneFilterWidht = UIHelper.Margins.large20px + textLenght + UIHelper.Margins.large20px

        let oneFilterVM = OneFilterCellViewModel(
            id: String(id),
            oneFilterTitle: oneFilterTitle,
            oneFilterTitleColor: oneFilterTitleColor,
            filterCounterBackColor: filterCounterBackColor,
            filterCounterText: filterCounterText,
            insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))

        return (AnyDifferentiable(oneFilterVM), oneFilterWidht)
    }

}
