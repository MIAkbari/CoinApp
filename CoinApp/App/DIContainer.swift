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
final class DIContainer {
    
    static let shared = DIContainer()
    
    private init() {}
    
    func makeAPIClient() -> APIClient {
        APIClient()
    }
    
    func makeNetworkMonitor() -> NetworkMonitor {
        NetworkMonitor()
    }
    
    func makeCoinRemoteDataSource() -> CoinRemoteDataSourceProtocol {
        CoinRemoteDataSource(apiClient: makeAPIClient())
    }
    
    func makeCoinLocalDataSource() -> CoinLocalDataSourceProtocol {
        CoinLocalDataSource()
    }
    
    func makeCoinRepository() -> CoinRepositoryProtocol {
        CoinRepository(
            remoteDataSource: makeCoinRemoteDataSource(),
            localDataSource: makeCoinLocalDataSource(),
            networkMonitor: makeNetworkMonitor()
        )
    }
    
    func makeFetchCoinsUseCase() -> FetchCoinsUseCase {
        FetchCoinsUseCase(repository: makeCoinRepository())
    }
    
    func makeCoinListViewModel() -> CoinListViewModel {
        CoinListViewModel(
            fetchCoinsUseCase: makeFetchCoinsUseCase(),
            networkMonitor: makeNetworkMonitor()
        )
    }
}
