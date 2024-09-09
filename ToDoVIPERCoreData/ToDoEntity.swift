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

    enum FilterType {
        case all, opened, closed
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
    let completed: Bool
    let userId: Int
}



// Бизнес-модель одной задачи
struct Task {
    let id: Int
    var description: String
    let isCompleted: Bool
    let userId: Int

    // Инициализатор из DTO
    init(from dto: DTOTask) {
        self.id = dto.id
        self.description = dto.todo
        self.isCompleted = dto.completed
        self.userId = dto.userId
    }
}
#warning("не понятно, что за свойства skip, userId: Int - в условии?")
#warning("не понятно, куда записывать Subtitle task'a, время выполнения - на UI он есть - в данных из сети нет таких полей")
// Бизнес-модель списка задач
struct TaskList {
    var tasks: [Task]
    let total: Int
    let skip: Int
    let limit: Int

    // Инициализатор для сети из DTO
    init(from dto: DTOTaskList) {
        self.tasks = dto.todos.map { Task(from: $0) }
        self.total = dto.total
        self.skip = dto.skip
        self.limit = dto.limit
    }
    // Инициализатор для создания TaskList
    init(tasks: [Task], total: Int, skip: Int, limit: Int) {
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
