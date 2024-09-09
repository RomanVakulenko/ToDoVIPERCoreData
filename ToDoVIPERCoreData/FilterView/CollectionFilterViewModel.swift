//
//  CollectionFilterViewModel.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import DifferenceKit


struct CollectionFilterViewModel {
    let id: String
    let backColor: UIColor
    let insets: UIEdgeInsets

    let items: [AnyDifferentiable]
    let widths: [CGFloat]

    init(id: String, backColor: UIColor, insets: UIEdgeInsets, items: [AnyDifferentiable], widths: [CGFloat]) {
        self.id = id
        self.backColor = backColor
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
        source.insets == insets &&
        source.widths == widths
    }
}

