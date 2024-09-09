//
//  ToDoCellViewModelOutput.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit

protocol ToDoCellViewModelOutput: AnyObject {
    func didTapTaskCell(_ viewModel: ToDoCellViewModel)
    func didTapCheckMark(_ viewModel: ToDoCellViewModel)
    func didSwipeLeftToDelete(_ viewModel: ToDoCellViewModel)
}

struct ToDoCellViewModel {
    let id: String
    let backColor: UIColor
    let taskNameText: NSAttributedString
    let taskSubtitleText: NSAttributedString
    let checkMarkImage: UIImage
    let separatorColor: UIColor
    let todaySubtitle: String
    let timeSubtitle: String
    let insets: UIEdgeInsets

    weak var output: ToDoCellViewModelOutput?
    
    init(id: String, backColor: UIColor, taskNameText: NSAttributedString, taskSubtitleText: NSAttributedString, checkMarkImage: UIImage, separatorColor: UIColor, todaySubtitle: String, timeSubtitle: String, insets: UIEdgeInsets, output: ToDoCellViewModelOutput? = nil) {
        self.id = id
        self.backColor = backColor
        self.taskNameText = taskNameText
        self.taskSubtitleText = taskSubtitleText
        self.checkMarkImage = checkMarkImage
        self.separatorColor = separatorColor
        self.todaySubtitle = todaySubtitle
        self.timeSubtitle = timeSubtitle
        self.insets = insets
        self.output = output
    }

    func didTapCell() {
        output?.didTapTaskCell(self)
    }

    func didTapCheckView() {
        output?.didTapCheckMark(self)
    }

    func didSwipeLeftToDelete() {
        output?.didSwipeLeftToDelete(self)
    }
}


extension ToDoCellViewModel: Differentiable {
    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: ToDoCellViewModel) -> Bool {
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

