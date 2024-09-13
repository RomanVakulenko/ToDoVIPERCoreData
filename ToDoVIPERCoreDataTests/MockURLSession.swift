//  MockURLSession.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

import Foundation

final class MockURLSession {
    var data: Data?
    var error: Error?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(data, nil, error)
        return URLSessionDataTask()
    }
}

