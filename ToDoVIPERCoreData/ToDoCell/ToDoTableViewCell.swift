//
//  ToDoTableViewCell.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit
import SnapKit


final class ToDoTableViewCell: BaseTableViewCell<ToDoCellViewModel> {

    // MARK: - Private properties

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIHelper.Color.grayBack
        return view
    }()

    private lazy var taskName: UITextField = {
        let label = UITextField()
        label.textColor = UIColor.black
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 18)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var taskSubtitle: UITextField = {
        let label = UITextField()
        label.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private lazy var checkMarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage.init(systemName: "circle"))
        imageView.backgroundColor = .none
        imageView.layer.cornerRadius = 19
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var separatorView: UIView = {
        let line = UIView()
        line.layer.borderWidth = 1
        line.layer.borderColor = UIHelper.Color.lightGrayTimeAndSeparator.cgColor

        return line
    }()

    private lazy var todaySubtitle: UITextField = {
        let label = UITextField()
        label.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    private lazy var timeSubtitle: UITextField = {
        let label = UITextField()
        label.textColor = UIHelper.Color.lightGrayTimeAndSeparator
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()


    // MARK: - Public methods

    override func update(with viewModel: ToDoCellViewModel) {
        contentView.backgroundColor = viewModel.backColor
        taskName.text = viewModel.taskNameText
        taskSubtitle.text = viewModel.taskSubtitleText
        checkMarkImageView.image = viewModel.checkMarkImage
        separatorView.backgroundColor = viewModel.separatorColor
        todaySubtitle.text = viewModel.todaySubtitle
        timeSubtitle.text = viewModel.timeSubtitle

        updateConstraints(insets: viewModel.insets)
    }

    override func composeSubviews() {
        contentView.addSubview(backView)
        [taskName, taskSubtitle, checkMarkImageView, separatorView, todaySubtitle, timeSubtitle].forEach { backView.addSubview($0) }

        let tapAtCheckMark = UITapGestureRecognizer(target: self, action: #selector(checkMarkTapped(_:)))
        checkMarkImageView.addGestureRecognizer(tapAtCheckMark)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAtCell(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        taskName.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        taskName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        taskSubtitle.snp.makeConstraints {
            $0.top.equalTo(taskName).offset(UIHelper.Margins.small4px)
            $0.leading.equalToSuperview()
        }
        taskSubtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        separatorView.snp.makeConstraints {
            $0.top.equalTo(taskSubtitle).offset(UIHelper.Margins.small4px)
            $0.leading.trailing.equalToSuperview()
        }

        checkMarkImageView.snp.makeConstraints {
            $0.bottom.equalTo(separatorView).offset(-UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        todaySubtitle.snp.makeConstraints {
            $0.top.equalTo(separatorView).offset(UIHelper.Margins.medium8px)
            $0.leading.equalToSuperview()
        }

        timeSubtitle.snp.makeConstraints {
            $0.top.equalTo(todaySubtitle)
            $0.leading.equalTo(todaySubtitle).offset(UIHelper.Margins.small4px)
        }
    }


    // MARK: - Private methods

    ///Must have the same set of constraints as makeConstraints method
    private func updateConstraints(insets: UIEdgeInsets) {
        backView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(insets.top) //all 16
            $0.leading.equalToSuperview().offset(insets.left)
            $0.bottom.equalToSuperview().inset(insets.bottom)
            $0.trailing.equalToSuperview().inset(insets.right)
        }
    }

    // MARK: - Actions
    @objc func checkMarkTapped(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapCheckView()
    }

    @objc func didTapAtCell(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapCell()
    }

}
