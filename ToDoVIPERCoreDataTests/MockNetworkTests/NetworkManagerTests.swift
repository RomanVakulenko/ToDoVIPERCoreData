//
//  NetworkManagerTests.swift
//  ToDoVIPERCoreDataTests
//
//  Created by Roman Vakulenko on 13.09.2024.
//


import XCTest
@testable import ToDoVIPERCoreData

final class NetworkManagerTests: XCTestCase {

    var sut: NetworkManager! // System Under Test
    var mockNetworkService: MockNetworkService!
    var mockDataMapper: MockDataMapper!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockDataMapper = MockDataMapper()
        sut = NetworkManager(networkService: mockNetworkService,
                             mapper: mockDataMapper)
    }

    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockDataMapper = nil
        super.tearDown()
    }

    func testLoadDataSuccess() {
        let expectedDTO = DTOTaskList(todos: [], total: 0, skip: 0, limit: 0)
        mockNetworkService.result = .success(Data()) // Симуляция успешного запроса
        mockDataMapper.result = .success(expectedDTO) // Симуляция успешного маппинга

        let expectation = XCTestExpectation(description: "LoadData Success")

        sut.loadData { result in
            switch result {
            case .success(let taskList):
                XCTAssertEqual(taskList.tasks.count, expectedDTO.todos.count)
                expectation.fulfill()
            case .failure:
                XCTFail("Expected success but got failure")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
