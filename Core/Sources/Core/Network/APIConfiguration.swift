//
//  APIConfiguration.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

import Foundation

// MARK: - Configuration
public struct APIConfiguration: Sendable {
    public let baseURL: String
    public let apiKey: String?
    
    public static let `default` = APIConfiguration(
        baseURL: "https://api.coingecko.com",
        apiKey: nil
    )
}
