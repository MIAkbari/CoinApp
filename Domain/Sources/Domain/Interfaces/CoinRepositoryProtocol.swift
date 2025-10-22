//
//  File.swift
//  Domain
//
//  Created by Mohammad on 10/21/25.
//

// Domain/Repositories/CoinRepositoryProtocol.swift
import Foundation

// MARK: - Repository
public protocol CoinRepositoryProtocol: Sendable {
    func fetchCoins(forceRefresh: Bool) async throws -> [Coin]
    func getCachedCoins() async throws -> [Coin]
    func refreshCoins() async throws -> [Coin]
    func autoRefreshOnReconnection() async throws -> [Coin]?
}
