//
//  MockNetworkService.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 10.09.2024.
//

import Foundation


final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<Data, NetServiceError>?

    func requestDataWith(_ urlRequest: URLRequest, completion: @escaping NetworkServiceCompletion) {
        if let result = result {
            completion(result)
        }
    }
}

final class MockDataMapper: DataMapperProtocol {
    var result: Result<DTOTaskList, DataMapperError>?

    func decode<T: Decodable>(from data: Data, toStruct type: T.Type, completion: @escaping (Result<T, DataMapperError>) -> Void) {
        if let result = result as? Result<T, DataMapperError> {
            completion(result)
        }
    }
}
