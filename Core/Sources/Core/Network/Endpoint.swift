//
//  Endpoint.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//


// Data/Network/Endpoint.swift
import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Infrastructure
public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]
    public let configuration: APIConfiguration
    
    public var url: URL? {
        var components = URLComponents(string: configuration.baseURL)
        components?.path = path.hasPrefix("/") ? path : "/" + path
        components?.queryItems = queryItems.isEmpty ? nil : queryItems
        return components?.url
    }
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        configuration: APIConfiguration = .default
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.configuration = configuration
    }
}
