//
//  ToDoScreenFlow.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation

enum ToDoScreenFlow {

    enum Update {

        struct Request {
            var filterType: ToDoModel.FilterType
        }

        struct Response {
            let taskList: TaskList
            let totalTasks: Int
            let completedTasksCount: Int?
            let filterType: ToDoModel.FilterType
        }

        typealias ViewModel = ToDoModel.ViewModel
    }

    enum OnFilterTapped {

        struct Request {
            let filterType: ToDoModel.FilterType
        }

        struct Response { }

        struct ViewModel { }
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {
            let taskList: TaskList
        }

        struct ViewModel {}
    }

    enum OnCheckMarkOrSwipe {

        struct Request {
            let id: String
        }

        struct Response {}

        struct ViewModel {}
    }

    enum OnTextChanged{

        struct Request {
            let id: String
            let taskNameText: String?
            let taskSubtitleText: String?
            let timeSubtitleText: String?
        }

        struct Response {}

        struct ViewModel {}
    }

    enum OnNewTaskButton {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnSelectItem {

        struct Request {
            let taskId: String?
        }

        struct Response {
            let taskId: String
        }

        struct ViewModel {
            let taskId: String
        }
    }

    enum RoutePayload {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnWaitIndicator {

        struct Request {}

        struct Response {
            let isShow: Bool
        }

        struct ViewModel {
            let isShow: Bool
        }
    }

    enum AlertInfo {

        struct Request {}

        struct Response {
            let error: Error?
        }

        struct ViewModel {
            let title: String?
            let text: String?
            let firstButtonTitle: String?
        }
    }
}
