//
//  ToDoView.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation
import SnapKit


protocol ToDoViewOutput: AnyObject,
                         ToDoTableCellViewModelOutput,
                         CollectionFilterViewOutput {
    func didTapNewTaskButton()
}

protocol ToDoViewLogic: UIView {
    func update(viewModel: ToDoModel.ViewModel)
    func displayWaitIndicator(viewModel: ToDoScreenFlow.OnWaitIndicator.ViewModel)

    var output: ToDoViewOutput? { get set }
}


final class ToDoScreenView: UIView, ToDoViewLogic, SpinnerDisplayable {


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
        view.backgroundColor = UIHelper.Color.blueBackNewTask
        view.layer.cornerRadius = UIHelper.Margins.medium8px
        view.addTarget(self, action: #selector(didTapNewTaskButton(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var filterView: CollectionFilterView = {
        let view = CollectionFilterView()
        return view
    }()

    private let tableView = UITableView()

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
        backgroundColor = viewModel.backViewColor
        backView.backgroundColor = viewModel.backViewColor

        if newTaskButton.backgroundColor != viewModel.newTaskButtonTitle {
            newTaskButton.setAttributedTitle(viewModel.newTaskButtonTitle, for: .normal)
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

        tableView.reloadData()
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
        tableView.register(cellType: ToDoTableViewCell.self)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delaysContentTouches = false
    }


    private func addSubviews() {
        self.addSubview(backView)
        [screenTitle, subtitle, newTaskButton, filterView, tableView].forEach { backView.addSubview($0) }
    }

    private func configureConstraints() {
        backView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        screenTitle.snp.makeConstraints {
            $0.top.equalTo(backView.snp.top).offset(UIHelper.Margins.large22px)
            $0.leading.equalToSuperview()
        }

        subtitle.snp.makeConstraints {
            $0.top.equalTo(screenTitle.snp.bottom).offset(UIHelper.Margins.medium8px)
            $0.leading.equalToSuperview()
        }

        newTaskButton.snp.makeConstraints {
            $0.top.equalTo(backView.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.trailing.equalToSuperview()
        }

        filterView.snp.makeConstraints {
            $0.top.equalTo(subtitle.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.height.equalTo(UIHelper.Margins.large26px)
            $0.leading.equalToSuperview()
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(filterView.snp.bottom).offset(UIHelper.Margins.large26px)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}


// MARK: - UITableViewDataSource

extension ToDoScreenView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel?.items[indexPath.row].base

        if let vm = item as? ToDoCellViewModel {
            let cell = tableView.dequeueReusableCell(for: indexPath) as ToDoTableViewCell
            cell.viewModel = vm
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
