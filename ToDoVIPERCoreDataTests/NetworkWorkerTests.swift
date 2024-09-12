//
//  NetworkWorkerTests.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

//import XCTest

//final class NetworkWorkerTests: XCTestCase {
//
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
//
//final class ToDoNetworkWorkerTests: XCTestCase {
//
//    var sut: ToDoNetworkWorker! // System Under Test
//    var mockNetworkManager: MockNetworkManager!
//
//    override func setUp() {
//        super.setUp()
//        mockNetworkManager = MockNetworkManager()
//        sut = ToDoNetworkWorker(networkManager: mockNetworkManager)
//    }
//
//    override func tearDown() {
//        sut = nil
//        mockNetworkManager = nil
//        super.tearDown()
//    }
//
//    func testLoadToDosFromNetworkSuccess() {
//        let expectedTaskList = TaskList(tasks: [])
//        mockNetworkManager.result = .success(expectedTaskList)
//
//        let expectation = XCTestExpectation(description: "LoadToDos Success")
//
//        sut.loadToDosFromNetwork { result in
//            switch result {
//            case .success(let taskList):
//                XCTAssertEqual(taskList.tasks.count, expectedTaskList.tasks.count)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Expected success but got failure")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//
//    func testLoadToDosFromNetworkFailure() {
//        mockNetworkManager.result = .failure(NetworkManagerErrors.invalidRequest)
//
//        let expectation = XCTestExpectation(description: "LoadToDos Failure")
//
//        sut.loadToDosFromNetwork { result in
//            switch result {
//            case .failure(let error):
//                XCTAssertEqual(error as! NetworkManagerErrors, .invalidRequest)
//                expectation.fulfill()
//            case .success:
//                XCTFail("Expected failure but got success")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//}
//
//final class MockNetworkManager: NetworkManagerProtocol {
//    var result: Result<TaskList, Error>?
//
//    func loadData(completion: @escaping (Result<TaskList, Error>) -> Void) {
//        if let result = result {
//            completion(result)
//        }
//    }
//}
//
