//
//  FetchCoinsUseCase.swift
//  Domain
//
//  Created by Mohammad on 10/21/25.
//

import Foundation

// MARK: - Use Cases
public final class FetchCoinsUseCase: Sendable {
    private let repository: CoinRepositoryProtocol
    
    public init(repository: CoinRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(forceRefresh: Bool = false) async throws -> [Coin] {
        try await repository.fetchCoins(forceRefresh: forceRefresh)
    }
    
    public func executDetails(forceRefresh: Bool = false) async throws -> [Coin] {
        try await repository.fetchDetails(forceRefresh: forceRefresh)
    }
    
    //  auto-refresh
    public func executeAutoRefresh() async throws -> [Coin]? {
        try await repository.refreshCoins()
    }
}
