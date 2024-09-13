////  NetworkServiceTests.swift
////  ToDoVIPERCoreData
////
////  Created by Roman Vakulenko on 10.09.2024.
////
//
//import XCTest
//@testable import ToDoVIPERCoreData
//
//final class NetworkServiceTests: XCTestCase {
//
//    var sut: NetworkService! // System Under Test
//    var mockURLSession: MockURLSession!
//
//    override func setUp() {
//        super.setUp()
//        mockURLSession = MockURLSession()
//        sut = NetworkService()
//    }
//
//    override func tearDown() {
//        sut = nil
//        mockURLSession = nil
//        super.tearDown()
//    }
//
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
//
