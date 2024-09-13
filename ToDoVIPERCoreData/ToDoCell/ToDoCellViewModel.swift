//
//  ToDoCellViewModelOutput.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit

protocol ToDoCellViewModelOutput: AnyObject {
    func didTapCell(_ viewModel: ToDoCellViewModel)
    func didTapCheckMark(_ viewModel: ToDoCellViewModel)
    func didSwipeLeftToDelete(_ viewModel: ToDoCellViewModel)

}

protocol ToDoCellViewModelChangeTextOutput: AnyObject {
    func onChangeTextInTextView(_ viewModel: ToDoCellViewModel,
                                taskNameText: String,
                                taskSubtitleText: String,
                                timeSubtitleText: String)
}

struct ToDoCellViewModel {
    let id: String
    let backColor: UIColor
    let taskNameText: NSAttributedString
    let taskSubtitleText: NSAttributedString
    let checkMarkImage: UIImage?
    let separatorColor: UIColor
    let todaySubtitle: String
    let timeSubtitle: String
    let insets: UIEdgeInsets
    var isEditMode: Bool

    weak var output: ToDoCellViewModelOutput?
    weak var textOutput: ToDoCellViewModelChangeTextOutput?

    init(id: String, backColor: UIColor, taskNameText: NSAttributedString, taskSubtitleText: NSAttributedString, checkMarkImage: UIImage?, separatorColor: UIColor, todaySubtitle: String, timeSubtitle: String, insets: UIEdgeInsets, output: ToDoCellViewModelOutput? = nil, isEditMode: Bool) {
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
        self.isEditMode = isEditMode
    }

    func didTapCell() {
        output?.didTapCell(self)
    }

    func didTapCheckView() {
        output?.didTapCheckMark(self)
    }

    func didSwipeLeftToDelete() {
        output?.didSwipeLeftToDelete(self)
    }

    func onChangeText(taskNameText: String,
                      taskSubtitleText: String,
                      timeSubtitleText: String) {
        if isEditMode {
            textOutput?.onChangeTextInTextView(self,
                                               taskNameText: taskNameText,
                                               taskSubtitleText: taskSubtitleText,
                                               timeSubtitleText: timeSubtitleText)
        }
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

