//
//  NetworkManagerTests.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

//final class NetworkManagerTests: XCTestCase {
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
//import XCTest
//@testable import YourProject
//
//final class NetworkManagerTests: XCTestCase {
//
//    var sut: NetworkManager! // System Under Test
//    var mockNetworkService: MockNetworkService!
//    var mockDataMapper: MockDataMapper!
//
//    override func setUp() {
//        super.setUp()
//        mockNetworkService = MockNetworkService()
//        mockDataMapper = MockDataMapper()
//        sut = NetworkManager(networkService: mockNetworkService, mapper: mockDataMapper)
//    }
//
//    override func tearDown() {
//        sut = nil
//        mockNetworkService = nil
//        mockDataMapper = nil
//        super.tearDown()
//    }
//
//    func testLoadDataSuccess() {
//        let expectedDTO = DTOTaskList(tasks: [], total: 0, skip: 0, limit: 0)
//        mockNetworkService.result = .success(Data()) // Симуляция успешного запроса
//        mockDataMapper.result = .success(expectedDTO) // Симуляция успешного маппинга
//
//        let expectation = XCTestExpectation(description: "LoadData Success")
//
//        sut.loadData { result in
//            switch result {
//            case .success(let taskList):
//                XCTAssertEqual(taskList.tasks.count, expectedDTO.tasks.count)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Expected success but got failure")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//}
