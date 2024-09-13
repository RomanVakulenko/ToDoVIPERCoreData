//  MockNetworkService.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

import Foundation
@testable import ToDoVIPERCoreData

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<Data, NetServiceError>?

    func requestDataWith(_ urlRequest: URLRequest,
                         completion: @escaping NetworkServiceCompletion) {
        if let result = result {
            completion(result)
        }
    }
}

