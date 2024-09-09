//
//  ToDoView.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import SnapKit


protocol ToDoViewOutput: AnyObject,
                         ToDoTableViewCellViewOutput,
                         ToDoCellViewModelOutput,
                         CollectionFilterViewOutput {
    func didTapNewTaskButton()
}

protocol ToDoViewLogic: UIView {
    func update(viewModel: ToDoModel.ViewModel)
    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel)

    var output: ToDoViewOutput? { get set }
}


final class ToDoScreenView: UIView, ToDoViewLogic, SpinnerDisplayable {

    enum Constants {
        static let newButtonWidth: CGFloat = 128
        static let width: CGFloat = 140
    }

    // MARK: - Public properties

    weak var output: ToDoViewOutput?

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

    private lazy var subtitle: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont(name: "SFUIDisplay-Bold", size: 16)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    private lazy var newTaskButton: UIButton = {
        let view = UIButton(type: .system)
        view.backgroundColor = .none
        view.layer.cornerRadius = UIHelper.Margins.medium16px
        view.addTarget(self, action: #selector(didTapNewTaskButton(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var filterView: CollectionFilterView = {
        let view = CollectionFilterView()
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

    private var viewModel: ToDoModel.ViewModel?


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

    func update(viewModel: ToDoModel.ViewModel) {
        self.viewModel = viewModel

        if newTaskButton.titleLabel?.text != viewModel.newTaskButtonTitle.string {
            newTaskButton.setAttributedTitle(viewModel.newTaskButtonTitle, for: .normal)
            newTaskButton.backgroundColor = viewModel.newTaskButtonBackColor

            backgroundColor = viewModel.backViewColor
            backView.backgroundColor = viewModel.backViewColor
            screenTitle.attributedText = viewModel.screenTitle
            subtitle.attributedText = viewModel.subtitle
        }

        for (i, _) in viewModel.views.enumerated() {
            let viewModel = viewModel.views[i].base

            switch viewModel {
            case let vm as CollectionFilterViewModel:
                filterView.viewModel = vm
                filterView.update(viewModel: vm)
                filterView.output = output
            default:
                break
            }
        }

        collectionView.reloadData()
    }

    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel) {
        if viewModel.isShow {
            showSpinner()
        } else {
            hideSpinner()
        }
    }

    // MARK: - Actions
    @objc func didTapNewTaskButton(_ sender: UIButton) {
        output?.didTapNewTaskButton()
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
        [screenTitle, subtitle, newTaskButton, filterView, collectionView].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        screenTitle.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top).offset(UIHelper.Margins.large22px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
        }

        subtitle.snp.makeConstraints {
            $0.top.equalTo(screenTitle.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
        }

        newTaskButton.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top).offset(UIHelper.Margins.large26px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
            $0.height.equalTo(UIHelper.Margins.huge42px)
            $0.width.equalTo(Constants.newButtonWidth)
        }

        filterView.snp.makeConstraints {
            $0.top.equalTo(subtitle.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.height.equalTo(UIHelper.Margins.large30px)
            $0.leading.equalToSuperview().offset(UIHelper.Margins.medium16px)
            $0.trailing.equalToSuperview().offset(-UIHelper.Margins.medium16px)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.leading.equalToSuperview()
            $0.trailing.bottom.equalToSuperview()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ToDoScreenView: UICollectionViewDataSource {

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
            cell.viewModel?.output = output
            return cell
        } else {
            return UICollectionViewCell()
        }
    }

}

//MARK: - UICollectionViewDelegateFlowLayout

extension ToDoScreenView: UICollectionViewDelegateFlowLayout {

    private var inset: CGFloat { return UIHelper.Margins.medium16px }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - inset * 2
        var height: CGFloat = 112
        return CGSize(width: width, height: height)
    }
    //отступы по периметру дисплея
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    //spacing между рядами/строками для вертикальной коллекции
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout, 
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        UIHelper.Margins.medium16px
    }

}
