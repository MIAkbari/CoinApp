//
//  DIContainer.swift
//  CoinApp
//
//  Created by Mohammad on 10/21/25.
//

import Foundation
import Domain
import Core
import Data


// MARK: - Dependency Injection
@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    
    private init() {}
    
    public func makeAPIClient() -> APIClient {
        APIClient()
    }
    
    public func makeNetworkMonitor() -> NetworkMonitor {
        NetworkMonitor()
    }
    
    public func makeCoinRemoteDataSource() -> CoinRemoteDataSourceProtocol {
        CoinRemoteDataSource(apiClient: makeAPIClient())
    }
    
    public func makeCoinLocalDataSource() -> CoinLocalDataSourceProtocol {
        CoinLocalDataSource()
    }
    
    public func makeCoinRepository() -> CoinRepositoryProtocol {
        CoinRepository(
            remoteDataSource: makeCoinRemoteDataSource(),
            localDataSource: makeCoinLocalDataSource(),
            networkMonitor: makeNetworkMonitor()
        )
    }
    
    public func makeFetchCoinsUseCase() -> FetchCoinsUseCase {
        FetchCoinsUseCase(repository: makeCoinRepository())
    }
    
    public func makeCoinListViewModel() -> CoinListViewModel {
        CoinListViewModel(
            fetchCoinsUseCase: makeFetchCoinsUseCase(),
            networkMonitor: makeNetworkMonitor()
        )
    }
}

