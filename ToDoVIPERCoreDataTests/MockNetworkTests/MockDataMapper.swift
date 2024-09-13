//  MockDataMapper.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 13.09.2024.
//

import Foundation
@testable import ToDoVIPERCoreData

class MockDataMapper: DataMapper {
    var result: Result<DTOTaskList, DataMapperError> = .failure(.failAtMapping)

    override func decode<T>(from data: Data, toStruct: T.Type, completion: @escaping (Result<T, DataMapperError>) -> Void) where T : Decodable {
        DispatchQueue.main.async {
            completion(self.result as! Result<T, DataMapperError>)
        }
    }
}

