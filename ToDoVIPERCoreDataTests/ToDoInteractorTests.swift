//
//  ToDoInteractorTests.swift
//  ToDoVIPERCoreDataTests
//
//  Created by Roman Vakulenko on 13.09.2024.
//

import XCTest
@testable import ToDoVIPERCoreData

final class ToDoInteractorTests: XCTestCase {
    var sut: ToDoInteractor!
    var mockPresenter: MockToDoPresenter!
    var mockStorageWorker: MockStorageWorker!
    var mockNetworkWorker: MockNetworkWorker!

    override func setUp() {
        super.setUp()
        mockPresenter = MockToDoPresenter()
        mockStorageWorker = MockStorageWorker()
        mockNetworkWorker = MockNetworkWorker()
        sut = ToDoInteractor(networkWorker: mockNetworkWorker, storageWorker: mockStorageWorker)
        sut.presenter = mockPresenter
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        mockStorageWorker = nil
        mockNetworkWorker = nil
        super.tearDown()
    }

    func testDidTapFilter() {
        let task1 = OneTask(id: 1, description: "Task 1", subTitle: "", timeForToDo: "", isCompleted: true, userId: 1)
        let task2 = OneTask(id: 2, description: "Task 2", subTitle: "", timeForToDo: "", isCompleted: false, userId: 1)
        let taskList = TaskList(tasks: [task1, task2], total: 20, skip: 0, limit: 3)

        sut.taskListFromNetOrDB = taskList
        sut.filterType = .all

        let request = ToDoScreenFlow.OnFilterTapped.Request(filterType: .opened)
        sut.didTapFilter(request: request)

        XCTAssertNotNil(mockPresenter.didUpdateUIWithTaskList, "Presenter should receive updated task list")
        XCTAssertEqual(mockPresenter.didUpdateUIWithTaskList?.tasks.count, 1, "Presenter should receive the correct number of tasks")
        XCTAssertEqual(mockPresenter.didUpdateUIWithTaskList?.tasks.first?.id, 2, "Presenter should receive the task with the correct ID")
    }

    func testDidTapCheckMarkWith() {
        let task1 = OneTask(id: 1, description: "Task 1", subTitle: "", timeForToDo: "", isCompleted: false, userId: 1)
        let task2 = OneTask(id: 2, description: "Task 2", subTitle: "", timeForToDo: "", isCompleted: false, userId: 1)
        let taskList = TaskList(tasks: [task1, task2], total: 20, skip: 0, limit: 3)

        sut.taskListFromNetOrDB = taskList
        let request = ToDoScreenFlow.OnCheckMarkOrSwipe.Request(id: "1")

        sut.didTapCheckMarkWith(request: request)

        XCTAssertEqual(sut.taskListFromNetOrDB?.tasks.first(where: { $0.id == 1 })?.isCompleted, true, "Task completion status should be toggled")
        XCTAssertNotNil(mockPresenter.didUpdateUIWithTaskList, "Presenter should receive updated task list")
        XCTAssertEqual(mockPresenter.didUpdateUIWithTaskList?.tasks.first(where: { $0.id == 1 })?.isCompleted, true, "Presenter should receive updated task status")
        XCTAssertNotNil(mockStorageWorker.savedTaskList, "Saved task list should not be nil")
        XCTAssertEqual(mockStorageWorker.savedTaskList?.tasks.first(where: { $0.id == 1 })?.isCompleted, true, "Saved task list should have updated task status")
    }
}


// MARK: - Mocks

protocol Mock {
    var didUpdateUIWithTaskList: TaskList? { get set }
    var savedTaskList: TaskList? { get set }
    var saveError: Error? { get set }
}

class MockToDoPresenter: ToDoPresenterProtocol, Mock {
    var savedTaskList: TaskList?
    var saveError: Error?

    var viewController: ToDoViewProtocol?
    var interactor: ToDoInteractorProtocol?
    var router: ToDoRoutingLogic?

    var didUpdateUIWithTaskList: TaskList?

    func presentWaitIndicator(response: ToDoScreenFlow.OnWaitIndicator.Response) {}
    func presentToDoList(response: ToDoScreenFlow.Update.Response) {
        didUpdateUIWithTaskList = response.taskList
    }
    func getData(request: ToDoScreenFlow.OnDidLoadViews.Request) {}
    func didTapFilter(request: ToDoScreenFlow.OnFilterTapped.Request) {}
    func didTapCheckMark(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {}
    func onSelectItem(request: ToDoScreenFlow.OnSelectItem.Request) {}
    func addNewTask(request: ToDoScreenFlow.OnNewTaskButton.Request) {}
    func didSwipeLeftToDelete(request: ToDoScreenFlow.OnCheckMarkOrSwipe.Request) {}
    func presentRouteToAddOrEditTaskScreen(response: ToDoScreenFlow.OnSelectItem.Response) {}
    func presentAlert(response: ToDoScreenFlow.AlertInfo.Response) {}
}

class MockNetworkWorker: ToDoNetworkWorkerProtocol, Mock {
    var didUpdateUIWithTaskList: TaskList?
    var savedTaskList: TaskList?
    var saveError: Error?

    func loadToDosFromNetwork(completion: @escaping (Result<TaskList, Error>) -> Void) {}
}

class MockStorageWorker: StorageWorkerProtocol, Mock {
    var didUpdateUIWithTaskList: TaskList?
    var savedTaskList: TaskList?
    var saveError: Error?

    func isDBEmpty(completion: @escaping (Bool) -> Void) {}
    func fetchToDosFromDataBase(completion: @escaping (Result<TaskList, Error>) -> Void) {}
    func saveToDos(_ taskList: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        savedTaskList = taskList
        if let error = saveError {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}
