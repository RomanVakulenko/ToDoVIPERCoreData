//
//  OneFilterCellViewModel.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import UIKit
import DifferenceKit


// MARK: - CloudEmailAttachmentViewModelOutput
protocol OneFilterCellViewModelOutput: AnyObject {
    func didTapFilterCell(_ viewModel: OneFilterCellViewModel)
}

struct OneFilterCellViewModel {

    let id: String
    let typeOfFilterCell: ToDoModel.FilterType
    let oneFilterTitle: String
    let oneFilterTitleColor: UIColor
    let filterCounterBackColor: UIColor
    let filterCounterText: String
    let insets: UIEdgeInsets

    weak var output: OneFilterCellViewModelOutput?

    init(id: String, typeOfFilterCell: ToDoModel.FilterType, oneFilterTitle: String, oneFilterTitleColor: UIColor, filterCounterBackColor: UIColor, filterCounterText: String, insets: UIEdgeInsets, output: OneFilterCellViewModelOutput? = nil) {
        self.id = id
        self.typeOfFilterCell = typeOfFilterCell
        self.oneFilterTitle = oneFilterTitle
        self.oneFilterTitleColor = oneFilterTitleColor
        self.filterCounterBackColor = filterCounterBackColor
        self.filterCounterText = filterCounterText
        self.insets = insets
        self.output = output
    }


    func tapAtOneFilterCell() {
        output?.didTapFilterCell(self)
    }
}

// MARK: - Extensions

extension OneFilterCellViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: OneFilterCellViewModel) -> Bool {
        source.oneFilterTitle == oneFilterTitle &&
        source.typeOfFilterCell == typeOfFilterCell &&
        source.oneFilterTitleColor == oneFilterTitleColor &&
        source.filterCounterBackColor == filterCounterBackColor &&
        source.filterCounterText == filterCounterText
    }
}
