//
//  ToDoEntity.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//


import DifferenceKit
import UIKit

enum ToDoModel {

    enum Errors: Error {
        case cantFetchData
    }

    enum FilterType: String {
        case all = "All"
        case opened = "Opened"
        case closed = "Closed"
    }

    struct ViewModel {
//        let navBarBackground: UIColor
//        let navBar: CustomNavBar
        let screenTitle: NSAttributedString
        let subtitle: NSAttributedString
        let backViewColor: UIColor
        let newTaskButtonTitle: NSAttributedString
        let newTaskButtonBackColor: UIColor
        let views: [AnyDifferentiable]
        let items: [AnyDifferentiable]
    }
}

//DTO
struct DTOTaskList: Decodable {
    let todos: [DTOTask]
    let total: Int
    let skip: Int
    let limit: Int
}

struct DTOTask: Decodable {
    let id: Int
    let todo: String
    let subTitle: String?
    let timeForToDo: String?
    let completed: Bool
    let userId: Int
}

// Бизнес-модель одной задачи
struct OneTask {
    let id: Int
    var description: String
    var subTitle: String?
    var timeForToDo: String?
    var isCompleted: Bool
    let userId: Int

    // Инициализатор из DTO
    init(from dto: DTOTask) {
        self.id = dto.id
        self.description = dto.todo
        self.subTitle = dto.subTitle
        self.timeForToDo = dto.timeForToDo
        self.isCompleted = dto.completed
        self.userId = dto.userId
    }

    // Инициализатор из ViewModel
    init(from viewModel: ToDoCellViewModel) {
        self.id = Int(viewModel.id) ?? 0
        self.description = viewModel.taskNameText.string
        self.subTitle = viewModel.taskSubtitleText.string
        self.timeForToDo = viewModel.timeSubtitle
        self.isCompleted = false
        self.userId = Int.random(in: 1...1000)
    }
}
#warning("не понятно, что за свойства skip, userId: Int - в условии?")
// Бизнес-модель списка задач
struct TaskList {
    var tasks: [OneTask]
    let total: Int
    let skip: Int
    let limit: Int

    // Инициализатор из DTO
    init(from dto: DTOTaskList) {
        self.tasks = dto.todos.map { OneTask(from: $0) }
        self.total = dto.total
        self.skip = dto.skip
        self.limit = dto.limit
    }
    // Инициализатор для создания TaskList
    init(tasks: [OneTask], total: Int, skip: Int, limit: Int) {
        self.tasks = tasks
        self.total = total
        self.skip = skip
        self.limit = limit
    }

    mutating func updateTaskDescription(withId id: Int, newDescription: String) {
           if let index = tasks.firstIndex(where: { $0.id == id }) {
               tasks[index].description = newDescription
           }
       }
}
