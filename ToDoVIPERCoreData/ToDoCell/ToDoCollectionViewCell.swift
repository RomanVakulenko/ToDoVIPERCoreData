//
//  ToDoCollectionViewCell.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 04.09.2024.
//

import UIKit
import SnapKit


protocol ToDoTableViewCellViewOutput: AnyObject {
    func useCurrent(taskNameText: String?,
                    taskSubtitleText: String?,
                    timeSubtitleText: String?,
                    cellId: String)
}

final class ToDoCollectionViewCell: BaseCollectionViewCell<ToDoCellViewModel> {

    // MARK: - Private properties

    private let backView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UIHelper.Margins.medium12px
        return view
    }()

    private lazy var taskName: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    private lazy var taskSubtitle: UILabel = {
        let view = UILabel()
        view.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
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
    #warning("не понятно куда сохранять время выполнения и как хотели бы, чтобы выбирался диапазон выполнения, потому вписал хардом в презентере - чтобы на UI было ")
    private lazy var todaySubtitle: UILabel = {
        let view = UILabel()
        view.textColor = UIHelper.Color.graySubtitleAndFilterButtons
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        view.font = UIFont.boldSystemFont(ofSize: 14)
        return view
    }()

    private lazy var timeSubtitle: UILabel = {
        let view = UILabel()
        view.textColor = UIHelper.Color.lightGrayTimeAndSeparator
        view.font = UIFont(name: "SFUIDisplay-Bold", size: 14)
        view.font = UIFont.boldSystemFont(ofSize: 14)
        view.lineBreakMode = .byTruncatingTail
        return view
    }()

    weak var output: ToDoTableViewCellViewOutput?

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
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
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
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
        }

        timeSubtitle.snp.makeConstraints {
            $0.top.equalTo(todaySubtitle)
            $0.leading.equalTo(todaySubtitle).offset(UIHelper.Margins.small4px)
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

//extension ToDoTableViewCell: UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let currentText = textField.text as NSString? else { return true }
//
//        guard let cursorPosition = textField.selectedTextRange else { return true }
//        let updatedText = currentText.replacingCharacters(in: range, with: string)
//
//        // Устанавливаем текст в зависимости от текстового поля
//        if textField == self.taskName {
//            self.taskName.text = updatedText.lowercased()
//        } else if textField == self.taskSubtitle {
//            self.taskSubtitle.text = updatedText.lowercased()
//        } else if textField == self.timeSubtitle {
//            self.timeSubtitle.text = updatedText
//        }
//
//        output?.useCurrent(
//            taskNameText: self.taskName.text,
//            taskSubtitleText: self.taskSubtitle.text,
//            timeSubtitleText: self.timeSubtitle.text, 
//            cellId: self.viewModel?.id ?? "")
//
//        // Вычисляем новое положение курсора
//        let currentCursorPosition = textField.offset(from: textField.beginningOfDocument, to: cursorPosition.start)
//        let newCursorPosition: Int
//
//        if string.isEmpty { // Если удаляем символ
//            newCursorPosition = max(currentCursorPosition - 1, 0)
//        } else { // Если вводим символ
//            newCursorPosition = currentCursorPosition + string.count
//        }
//
//        // Устанавливаем новое положение курсора
//        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorPosition) {
//            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
//        }
//
//        return false
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}
