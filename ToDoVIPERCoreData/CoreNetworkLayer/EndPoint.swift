//
//  EndPoint.swift
//  ToDoVIPERCoreData
//
//  Created by Roman Vakulenko on 05.09.2024.
//

import Foundation

// MARK: - Endpoint
protocol Endpoint {
    var scheme: String? { get }
    var host: String? { get }
    var path: String { get set }
    var queryItems: [URLQueryItem]? { get set }
    var url: URL? { get }

}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}

// MARK: - Basic implementation
struct StandardEndpoint: Endpoint {
    var scheme: String? = "https"
    var host: String? = "dummyjson.com"
    var path: String = "/todos"
    var queryItems: [URLQueryItem]? = nil
}
