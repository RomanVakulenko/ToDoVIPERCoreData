//
//  NetServiceError.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation


enum NetServiceError: Error, CustomStringConvertible {
    case badInternetConnection
    case badStatusCode
    case unknownError
    case noData

    var description: String {
        switch self {
            ///Ошибка сетевого соединения (timeout, HTTP-статус 5xx и т.п.).
        case .badInternetConnection:
            return """
                    Unable to update data.
                    Please check your internet connection
                    """
            ///Ошибка сетевого соединения (timeout, HTTP-статус 5xx и т.п.).
        case .badStatusCode:
            return """
                    Unable to update data.
                    Something went wrong
                    """
        case .unknownError:
            return "Unknown server error"
        case .noData:
            return "Unable to retrieve data"
        }
    }
}
