//
//  ToDoEntity.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//


import DifferenceKit
import UIKit

enum EditTaskModel {

    enum Errors: Error {
        case errorAtSaving
        case errorAtDeleting
    }

    enum AlertAtOrCase {
        case savedSuccessfully
        case deletedSuccessfully
        case fillNeededFields
    }

    enum EditType {
        case add
        case edit
    }

    enum ButtonTitle {
        case save
        case delete
    }

    struct ViewModel {
        let backViewColor: UIColor
        let navBarBackground: UIColor
        let navBar: CustomNavBar
        let separatorColor: UIColor

        let saveButtonTitle: NSAttributedString
        let saveButtonBackColor: UIColor

        let deleteButtonTitle: NSAttributedString
        let deleteButtonBackColor: UIColor

        let items: [AnyDifferentiable]
    }
}
