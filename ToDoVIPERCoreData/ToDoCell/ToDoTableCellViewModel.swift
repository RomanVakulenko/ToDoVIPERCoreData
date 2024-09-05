//
//  ToDoTableCellViewModel.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit

protocol ToDoTableCellViewModelOutput: AnyObject {
    func didTapTaskCell(_ viewModel: ToDoCellViewModel)
    func didTapCheckMark(_ viewModel: ToDoCellViewModel)
}

struct ToDoCellViewModel {
    let id: String
    let backColor: UIColor
    let taskNameText: String
    let taskSubtitleText: String
    let checkMarkImage: UIImage
    let separatorColor: UIColor
    let todaySubtitle: String
    let timeSubtitle: String
    let insets: UIEdgeInsets
    let items: [AnyDifferentiable]

    weak var output: ToDoTableCellViewModelOutput?

    init(id: String, backColor: UIColor, taskNameText: String, taskSubtitleText: String, checkMarkImage: UIImage, separatorColor: UIColor, todaySubtitle: String, timeSubtitle: String, insets: UIEdgeInsets, items: [AnyDifferentiable], output: ToDoTableCellViewModelOutput? = nil) {
        self.id = id
        self.backColor = backColor
        self.taskNameText = taskNameText
        self.taskSubtitleText = taskSubtitleText
        self.checkMarkImage = checkMarkImage
        self.separatorColor = separatorColor
        self.todaySubtitle = todaySubtitle
        self.timeSubtitle = timeSubtitle
        self.insets = insets
        self.items = items
        self.output = output
    }

    func didTapCell() {
        output?.didTapTaskCell(self)
    }

    func didTapCheckView() {
        output?.didTapCheckMark(self)
    }
}


extension ToDoCellViewModel: Differentiable {
    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: ToDoCellViewModel) -> Bool {
        source.id == id &&
        source.backColor == backColor &&
        source.taskNameText == taskNameText &&
        source.taskSubtitleText == taskSubtitleText &&
        source.checkMarkImage == checkMarkImage &&
        source.separatorColor == separatorColor &&
        source.todaySubtitle == todaySubtitle &&
        source.timeSubtitle == timeSubtitle &&
        source.insets == insets
    }
}

