//
//  CoinRemoteDataSourceProtocol.swift
//  Data
//
//  Created by Mohammad on 10/21/25.
//

import Foundation
import Core

// MARK: - Data Sources
public protocol CoinRemoteDataSourceProtocol: Sendable {
    func fetchCoins() async throws -> [CoinDTO]
    func fetchDetils() async throws -> [CoinDTO]
}

public protocol CoinLocalDataSourceProtocol: Sendable {
    func saveCoins(_ coins: [CoinData]) async throws
    func getCoins() async throws -> [CoinData]
    func clearCoins() async throws
}

public final class CoinRemoteDataSource: CoinRemoteDataSourceProtocol {
    private let apiClient: APIClient
    
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    public func fetchCoins() async throws -> [CoinDTO] {
        let endpoint = Endpoint(
            path: "/api/v3/coins/markets",
            queryItems: [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "100"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sparkline", value: "false"),
                URLQueryItem(name: "price_change_percentage", value: "24h")
            ]
        )
        
        return try await apiClient.request(endpoint)
    }
    
    // test
    public func fetchDetils() async throws -> [CoinDTO] {
        let endpoint = Endpoint(
            path: "/api/v3/coins/markets",
            queryItems: [
                URLQueryItem(name: "vs_currency", value: "usd"),
                URLQueryItem(name: "order", value: "market_cap_desc"),
                URLQueryItem(name: "per_page", value: "1"),
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "sparkline", value: "true"),
                URLQueryItem(name: "price_change_percentage", value: "24h")
            ]
        )
        
        return try await apiClient.request(endpoint)
    }
}
