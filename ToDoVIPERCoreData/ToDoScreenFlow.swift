//
//  ToDoScreenFlow.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation

enum ToDoScreenFlow {

    enum Update {

        struct Request {}

        struct Response {
            let isCheckMarkTapped: Bool
        }

        typealias ViewModel = ToDoModel.ViewModel
    }

    enum OnDidLoadViews {

        struct Request {}

        struct Response {}

        struct ViewModel {}
    }

    enum OnCheckMark{

        struct Request {}

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
