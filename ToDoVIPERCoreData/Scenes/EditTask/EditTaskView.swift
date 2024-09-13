//
//  EditTaskView.swift
//  EditTaskVIPERCoreData
//
//  Created by Roman Vakulenko on 12.09.2024. //только сегодня получил ответ, что надо делать второй экран
//

import Foundation
import SnapKit


protocol EditTaskViewOutput: AnyObject,
                             ToDoCellViewModelChangeTextOutput {
    func didTapSaveButton()
    func didTapDeleteButton()
}

protocol EditTaskViewLogic: UIView {
    func update(viewModel: EditTaskModel.ViewModel)
    func displayWaitIndicator(viewModel: EditTaskScreenFlow.OnWaitIndicator.ViewModel)

    var output: EditTaskViewOutput? { get set }
}


final class EditTaskScreenView: UIView, EditTaskViewLogic, SpinnerDisplayable {

    enum Constants {
        static let newButtonWidth: CGFloat = 128
        static let width: CGFloat = 140
    }

    // MARK: - Public properties

    weak var output: EditTaskViewOutput?

    // MARK: - Private properties
    private lazy var backView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var screenTitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 20)
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var navBarSeparatorView: UIView = {
        let line = UIView()
        return line
    }()

    private lazy var saveButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .none
        view.layer.cornerRadius = UIHelper.Margins.medium16px
        view.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var deleteButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .none
        view.layer.cornerRadius = UIHelper.Margins.medium16px
        view.addTarget(self, action: #selector(didTapDeleteButton(_:)), for: .touchUpInside)
        return view
    }()

    private(set) lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: ToDoCollectionViewCell.self)
        collectionView.backgroundColor = .none
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private var viewModel: EditTaskModel.ViewModel?


    // MARK: - Init

    deinit { }

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = UIHelper.Color.grayBack
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Public Methods

    func update(viewModel: EditTaskModel.ViewModel) {
        self.viewModel = viewModel

        if saveButton.titleLabel?.text != viewModel.saveButtonTitle.string {
            saveButton.setAttributedTitle(viewModel.saveButtonTitle, for: .normal)
            saveButton.backgroundColor = viewModel.saveButtonBackColor

            deleteButton.setAttributedTitle(viewModel.deleteButtonTitle, for: .normal)
            deleteButton.backgroundColor = viewModel.deleteButtonBackColor

            backgroundColor = viewModel.backViewColor
            backView.backgroundColor = viewModel.backViewColor
            navBarSeparatorView.layer.borderColor = viewModel.separatorColor.cgColor
            navBarSeparatorView.layer.borderWidth = UIHelper.Margins.small1px
        }

        collectionView.reloadData()
    }

    func displayWaitIndicator(viewModel: EditTaskScreenFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner()
        } else {
            hideSpinner()
        }
    }

    // MARK: - Actions
    @objc func didTapSaveButton(_ sender: UIButton) {
        output?.didTapSaveButton()
    }

    @objc func didTapDeleteButton(_ sender: UIButton) {
        output?.didTapDeleteButton()
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
        collectionView.register(cellType: ToDoCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
    }


    private func addSubviews() {
        self.addSubview(backView)
        [screenTitle, navBarSeparatorView, saveButton, deleteButton, collectionView].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        navBarSeparatorView.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top)
            $0.height.equalTo(UIHelper.Margins.small1px)
            $0.leading.trailing.equalToSuperview()
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(navBarSeparatorView.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
            $0.height.equalTo(UIHelper.Margins.huge42px)
            $0.width.equalTo(Constants.newButtonWidth)
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalTo(navBarSeparatorView.snp.top).offset(UIHelper.Margins.large26px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.height.equalTo(UIHelper.Margins.huge42px)
            $0.width.equalTo(Constants.newButtonWidth)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.leading.equalToSuperview()
            $0.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension EditTaskScreenView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = viewModel?.items[indexPath.item].base

        if let vm = item as? ToDoCellViewModel {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as ToDoCollectionViewCell
            cell.viewModel = vm
            cell.viewModel?.textOutput = output
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

}

//MARK: - UICollectionViewDelegateFlowLayout

extension EditTaskScreenView: UICollectionViewDelegateFlowLayout {

    private var inset: CGFloat { return UIHelper.Margins.medium16px }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - inset * 2
        var height: CGFloat = 112
        return CGSize(width: width, height: height)
    }
    //spacing между рядами/строками для вертикальной коллекции
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        UIHelper.Margins.medium16px
    }

}
