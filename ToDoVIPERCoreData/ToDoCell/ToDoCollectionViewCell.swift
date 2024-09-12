//
//  ToDoCollectionViewCell.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit
import SnapKit


protocol ToDoCollectionViewCellViewOutput: AnyObject { }

final class ToDoCollectionViewCell: BaseCollectionViewCell<ToDoCellViewModel> {

    // MARK: - Private properties

    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIHelper.Margins.medium12px
        return view
    }()

    private lazy var taskName: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.textContainer.maximumNumberOfLines = 1
        view.textContainer.lineBreakMode = .byTruncatingTail
        view.textContainerInset = .zero
        view.textAlignment = .left
        view.delegate = self
        return view
    }()

    private lazy var taskSubtitle: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.textContainer.maximumNumberOfLines = 1
        view.textContainer.lineBreakMode = .byTruncatingTail
        view.textContainerInset = .zero
        view.textAlignment = .left
        view.delegate = self
        return view
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
    #warning("не понятно как хотели бы, чтобы выбирался диапазон выполнения, потому вписал хардом в презентере - чтобы на UI было ")
    private lazy var todaySubtitle: UILabel = {
        let view = UILabel()
        view.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        view.font = UIFont.boldSystemFont(ofSize: 14)
        return view
    }()

    private lazy var timeSubtitle: UITextView = {
        let view = UITextView()
        view.isScrollEnabled = false
        view.textContainer.maximumNumberOfLines = 1
        view.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.textContainer.lineBreakMode = .byTruncatingTail
        view.textContainerInset = .zero
        view.textAlignment = .left
        view.delegate = self
        return view
    }()

    weak var output: ToDoCollectionViewCellViewOutput?

    // MARK: - Public methods

    override func update(with viewModel: ToDoCellViewModel) {
        contentView.backgroundColor = .none
        backView.backgroundColor = .white
        taskName.attributedText = viewModel.taskNameText
        taskSubtitle.attributedText = viewModel.taskSubtitleText
        checkMarkImageView.image = viewModel.checkMarkImage
        separatorView.backgroundColor = viewModel.separatorColor
        todaySubtitle.text = viewModel.todaySubtitle
        timeSubtitle.text = viewModel.timeSubtitle

        let isEditMode = viewModel.isEditMode
        taskName.isUserInteractionEnabled = isEditMode
        taskSubtitle.isUserInteractionEnabled = isEditMode
        timeSubtitle.isUserInteractionEnabled = isEditMode

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

        // Свайп для удаления
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeGestureRecognizer.direction = .left
        backView.addGestureRecognizer(swipeGestureRecognizer)
    }

    override func setConstraints() {
        backView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }

        taskName.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.huge42px)
        }
        taskName.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        taskSubtitle.snp.makeConstraints {
            $0.top.equalTo(taskName.snp.bottom).offset(UIHelper.Margins.small4px)
            $0.leading.equalTo(taskName.snp.leading)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.huge40px)
        }
        taskSubtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        separatorView.snp.makeConstraints {
            $0.top.equalTo(taskSubtitle.snp.bottom).offset(UIHelper.Margins.medium12px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.large20px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
            $0.height.equalTo(UIHelper.Margins.small1px)
        }

        checkMarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIHelper.Margins.large20px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
            $0.height.width.equalTo(UIHelper.Margins.large30px)
        }

        todaySubtitle.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(UIHelper.Margins.medium12px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.large20px)
        }

        timeSubtitle.snp.makeConstraints {
            $0.top.equalTo(todaySubtitle)
            $0.leading.equalTo(todaySubtitle.snp.trailing).offset(UIHelper.Margins.small4px)
        }
        timeSubtitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
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

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        viewModel?.didSwipeLeftToDelete()
    }

    @objc func checkMarkTapped(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapCheckView()
    }

    @objc func didTapAtCell(_ sender: UITapGestureRecognizer) {
        viewModel?.didTapCell() //для предполагаемого перехода на детальный экран Task'a - но он не заявлен в ТЗ
    }

}

// MARK: - UITextViewDelegate
extension ToDoCollectionViewCell: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text as NSString? else { return true }

        // Первая заглавная
        let isFirstCharacter = range.location == 0
        let transformedText = isFirstCharacter ? text.capitalized : text.lowercased()

        let updatedText = currentText.replacingCharacters(in: range, with: transformedText)

        if textView == self.taskName {
            self.taskName.text = updatedText
        } else if textView == self.taskSubtitle {
            self.taskSubtitle.text = updatedText
        } else if textView == self.timeSubtitle {
            self.timeSubtitle.text = updatedText
        }

        viewModel?.onChangeText(
            taskNameText: self.taskName.text,
            taskSubtitleText: self.taskSubtitle.text,
            timeSubtitleText: self.timeSubtitle.text ?? "")

        return false
    }


    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}

