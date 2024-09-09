//
//  CollectionFilterView.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import UIKit
import SnapKit

protocol CollectionFilterViewOutput: AnyObject, OneFilterCellViewModelOutput { }


protocol CollectionFilterViewLogic: UIView {
    func update(viewModel: CollectionFilterViewModel)
//    func displayWaitIndicator(viewModel: OneEmailAttachmentFlow.OnWaitIndicator.ViewModel)

    var output: CollectionFilterViewOutput? { get set }
}


final class CollectionFilterView: UIView, CollectionFilterViewLogic {

    // MARK: - Public properties

    weak var output: CollectionFilterViewOutput?
    var viewModel: CollectionFilterViewModel?

    // MARK: - Private properties

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .none
        return view
    }()

    private(set) lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(cellType: OneFilterCell.self)
        collectionView.register(cellType: SeparatorCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .none
        return collectionView
    }()

    private var cellWidths = [CGFloat]()

    // MARK: - Init

    deinit { }

    override init(frame: CGRect = CGRect.zero) {
        super.init(frame: frame)
        configure()
        backgroundColor = .none
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func update(viewModel: CollectionFilterViewModel) {
        self.viewModel = viewModel
        backView.layer.backgroundColor = .none
        cellWidths = viewModel.widths

        updateConstraints(insets: viewModel.insets)
        collectionView.reloadData()
    }

    // MARK: - Private Methods

    private func configure() {
        addSubviews()
        configureConstraints()
    }

    private func addSubviews() {
        self.addSubview(backView)
        backView.addSubview(collectionView)
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

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


// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionFilterView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard indexPath.item < cellWidths.count else { return CGSize.zero }
        let cellWidth = cellWidths[indexPath.item]

        return CGSize(width: cellWidth, height: UIHelper.Margins.huge36px)
    }
}


// MARK: - UICollectionViewDataSource

extension CollectionFilterView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = viewModel?.items[indexPath.item].base

        if let vm = item as? OneFilterCellViewModel {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as OneFilterCell
            cell.viewModel = vm
            cell.viewModel?.output = output
            return cell
        } else if let vm = item as? SeparatorCellViewModel {
            let cell = collectionView.dequeueReusableCell(for: indexPath) as SeparatorCell
            cell.viewModel = vm
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}
