//
//  SeparatorCellViewModel.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit

struct SeparatorCellViewModel {
    let id: AnyHashable
    let separatorColor: UIColor
    let separatorBorderWidth: CGFloat?
    let insets: UIEdgeInsets

    init(id: AnyHashable,
         separatorColor: UIColor,
         separatorBorderWidth: CGFloat? = nil,
         insets: UIEdgeInsets) {
        self.id = id
        self.separatorColor = separatorColor
        self.separatorBorderWidth = separatorBorderWidth
        self.insets = insets
    }
}


extension SeparatorCellViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: SeparatorCellViewModel) -> Bool {
        source.separatorColor == separatorColor &&
        source.insets == insets
    }
}
