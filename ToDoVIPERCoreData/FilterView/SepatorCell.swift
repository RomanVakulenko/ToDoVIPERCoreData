//
//  SepatorCell.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import UIKit
import SnapKit


final class SeparatorCell: BaseCollectionViewCell<SeparatorCellViewModel> {

    // MARK: - SubTypes

    private(set) lazy var backView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var separatorView: UIView = {
        let line = UIView()
        return line
    }()


    // MARK: - Public methods

    override func update(with viewModel: SeparatorCellViewModel) {
        backgroundColor = UIHelper.Color.grayBack
        backView.backgroundColor = UIHelper.Color.grayBack
        separatorView.layer.borderWidth = viewModel.separatorBorderWidth ?? 1
        separatorView.layer.borderColor = viewModel.separatorColor.cgColor

        updateConstraints(insets: viewModel.insets)

        layoutIfNeeded()
    }

    override func composeSubviews() {
        contentView.addSubview(backView)
        backView.addSubview(separatorView)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
            $0.width.equalTo(UIHelper.Margins.small1px)
        }
        separatorView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
            $0.width.equalTo(UIHelper.Margins.small1px)
        }
    }

    // MARK: - Private methods

    ///Must have the same set of constraints as makeConstraints method
    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(insets.top)
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalToSuperview().inset(insets.bottom)
            $0.trailing.equalToSuperview().inset(insets.right)
        }
    }

}

