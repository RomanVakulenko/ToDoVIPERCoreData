//
//  CollectionFilterViewModel.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit


struct CollectionFilterViewModel {
    let id: AnyHashable
    let backColor: UIColor
    let title: NSAttributedString
    let insets: UIEdgeInsets

    let items: [AnyDifferentiable]
    let widths: [CGFloat]

    init(id: AnyHashable, backColor: UIColor, title: NSAttributedString, insets: UIEdgeInsets, items: [AnyDifferentiable], widths: [CGFloat]) {
        self.id = id
        self.backColor = backColor
        self.title = title
        self.insets = insets
        self.items = items
        self.widths = widths
    }
}

extension CollectionFilterViewModel: Differentiable {
    var differenceIdentifier: AnyHashable {
        id
    }

    func isContentEqual(to source: CollectionFilterViewModel) -> Bool {
        source.backColor == backColor &&
        source.title == title &&
        source.insets == insets &&
        source.widths == widths
    }
}

