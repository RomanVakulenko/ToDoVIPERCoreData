//
//  OneFilterCell.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import UIKit
import SnapKit

final class OneFilterCell: BaseCollectionViewCell<OneFilterCellViewModel> {
//
//    enum Constants {
//        static let some
//    }

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        return view
    }()

    private lazy var oneFilterTitle: UILabel = {
        let view = UILabel()
        view.lineBreakMode = .byTruncatingTail
        view.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 16)
        view.font = UIFont.boldSystemFont(ofSize: 16)
        return view
    }()

    private lazy var filterCounter: UILabel = {
        let view = UILabel()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 6
        view.textColor = .white
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 16)
        view.font = UIFont.boldSystemFont(ofSize: 16)
        return view
    }()


    // MARK: - Public methods
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

   override func update(with viewModel: OneFilterCellViewModel) {
       contentView.backgroundColor = .none
       oneFilterTitle.text = viewModel.oneFilterTitle
       oneFilterTitle.textColor = viewModel.oneFilterTitleColor
       filterCounter.backgroundColor = viewModel.filterCounterBackColor
       filterCounter.text = viewModel.filterCounterText

       updateConstraints(insets: viewModel.insets)
       layoutIfNeeded()
   }

    override func composeSubviews() {
        backgroundColor = .none
        contentView.addSubview(backView)
        backView.addSubview(oneFilterTitle)
        backView.addSubview(filterCounter)

        let filterTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFilter(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(filterTapGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        oneFilterTitle.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }

        filterCounter.snp.makeConstraints {
            $0.centerY.equalTo(oneFilterTitle.snp.centerY)
            $0.leading.equalTo(oneFilterTitle.snp.trailing).offset(UIHelper.Margins.small4px)
            $0.trailing.equalToSuperview()
        }
    }

    // MARK: - Actions
    @objc private func didTapFilter(_ sender: UITapGestureRecognizer) {
        viewModel?.tapAtOneFilterCell()
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
