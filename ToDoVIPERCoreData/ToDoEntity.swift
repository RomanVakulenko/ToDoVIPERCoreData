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
        let backViewColor: UIColor
        let newTaskButtonTitle: NSAttributedString
        let views: [AnyDifferentiable]
        let items: [AnyDifferentiable]
    }



}

//
//
//struct ToDoModel: Decodable {
//    var id: Int
//    var name: String
//    var imageURL: String
//    var price: Int
//}
