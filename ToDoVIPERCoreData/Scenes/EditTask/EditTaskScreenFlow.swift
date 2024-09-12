//
//  EditTaskScreenFlow.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import Foundation

enum EditTaskScreenFlow {

    enum Update {

        struct Request { }

        struct Response {
            let totalTasks: Int
            let task: OneTask?
            let type: EditTaskModel.EditType
        }

        typealias ViewModel = EditTaskModel.ViewModel
    }


    enum OnDidLoadViews {

        struct Request {}

        struct Response {
            let taskList: TaskList
        }

        struct ViewModel {}
    }

    enum OnSaveOrDeleteTap {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }


    enum OnTextChanged{

        struct Request {
            let id: Int
            let taskNameText: String
            let taskSubtitleText: String
            let timeSubtitleText: String
        }

        struct Response {}

        struct ViewModel {}
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
            let error: EditTaskModel.Errors?
            let alertAt: EditTaskModel.AlertAtOrCase?
        }

        struct ViewModel {
            let title: String?
            let text: String?
            let firstButtonTitle: String?
        }
    }
}
