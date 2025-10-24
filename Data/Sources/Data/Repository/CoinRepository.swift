//
//  File.swift
//  Data
//
//  Created by Mohammad on 10/21/25.
//

// Data/Repositories/CoinRepository.swift
import Foundation
import Domain
import Core
import OSLog

public final class CoinRepository: CoinRepositoryProtocol, Sendable {
    private let remoteDataSource: CoinRemoteDataSourceProtocol
    private let localDataSource: CoinLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitor
    private let state = State()
    
    public init(
        remoteDataSource: CoinRemoteDataSourceProtocol,
        localDataSource: CoinLocalDataSourceProtocol,
        networkMonitor: NetworkMonitor
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }
    
    public func fetchCoins(forceRefresh: Bool = false) async throws -> [Coin] {
        let connectionStatus = await networkMonitor.connectionStatus
        
        if connectionStatus.isConnected {
            // ✅ فقط یک await
            let shouldRefresh = await state.getRefreshDecision(forceRefresh: forceRefresh)
            if shouldRefresh {
                return try await refreshCoins()
            } else {
                return try await getCachedCoins()
            }
        } else {
            return try await getCachedCoins()
        }
    }
    
    public func getCachedCoins() async throws -> [Coin] {
        let coinData = try await localDataSource.getCoins()
        return coinData.map(CoinMapper.toDomain)
    }
    
    public func refreshCoins() async throws -> [Coin] {
        do {
            let dtos = try await remoteDataSource.fetchCoins()
            let coinData = dtos.map(CoinMapper.toData)
            
            try await localDataSource.saveCoins(coinData)
            await state.updateLastRefreshTime()
            
            return dtos.map(CoinMapper.toDomain)
            
        } catch {
            let connectionStatus = await networkMonitor.connectionStatus
            if !connectionStatus.isConnected {
                return try await getCachedCoins()
            }
            throw error
        }
    }
    
    public func fetchDetails(forceRefresh: Bool) async throws -> [Coin] {
        do {
            let dtos = try await remoteDataSource.fetchDetils()
            return dtos.map(CoinMapper.toDomain)
        } catch {
            throw error
        }
    }
    
    public func autoRefreshOnReconnection() async throws -> [Coin]? {
        let connectionStatus = await networkMonitor.connectionStatus
        let shouldRefresh = await state.shouldRefreshFromNetwork()
        
        if connectionStatus.isConnected && shouldRefresh {
            return try await refreshCoins()
        }
        return nil
    }
}

private actor State {
    var lastRefreshTime: Date?
    let cacheValidityInterval: TimeInterval = 300
    
    func updateLastRefreshTime() {
        lastRefreshTime = Date()
    }
    
    func shouldRefreshFromNetwork() -> Bool {
        guard let lastRefresh = lastRefreshTime else { return true }
        return Date().timeIntervalSince(lastRefresh) > cacheValidityInterval
    }
    
    // ✅ for limit of await
    func getRefreshDecision(forceRefresh: Bool) -> Bool {
        if forceRefresh {
            return true
        }
        guard let lastRefresh = lastRefreshTime else { return true }
        return Date().timeIntervalSince(lastRefresh) > cacheValidityInterval
    }
}
