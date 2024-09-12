//
//  NetworkServiceTests.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

//import XCTest

//final class NetworkServiceTests: XCTestCase {
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
//final class NetworkServiceTests: XCTestCase {
//
//    var sut: NetworkService! // System Under Test
//    var mockURLSession: MockURLSession!
//
//    override func setUp() {
//        super.setUp()
//        mockURLSession = MockURLSession()
//        sut = NetworkService() // Можем передать сессионный мок в инициализатор
//    }
//
//    override func tearDown() {
//        sut = nil
//        mockURLSession = nil
//        super.tearDown()
//    }
//
//    // Пример теста для случая успешного запроса
//    func testRequestDataWithSuccess() {
//        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
//        let expectedData = Data([0, 1, 0, 1])
//        mockURLSession.data = expectedData
//
//        let expectation = XCTestExpectation(description: "RequestData Success")
//
//        sut.requestDataWith(urlRequest) { result in
//            switch result {
//            case .success(let data):
//                XCTAssertEqual(data, expectedData)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Expected success but got failure")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//
//    // Пример теста для ошибки тайм-аута
//    func testRequestDataWithTimeoutError() {
//        let urlRequest = URLRequest(url: URL(string: "https://example.com")!)
//        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
//        mockURLSession.error = error
//
//        let expectation = XCTestExpectation(description: "RequestData Timeout Error")
//
//        sut.requestDataWith(urlRequest) { result in
//            switch result {
//            case .failure(let error):
//                XCTAssertEqual(error, .badInternetConnection)
//                expectation.fulfill()
//            case .success:
//                XCTFail("Expected failure but got success")
//            }
//        }
//
//        wait(for: [expectation], timeout: 1.0)
//    }
//}
