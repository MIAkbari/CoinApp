////
////  CoinsListViewModel.swift
////  CoinApp
////
////  Created by Mohammad on 10/21/25.
////

import Foundation
import Combine
import Domain
import Core
import Data
import OSLog

// MARK: - Presentation Layer
@MainActor
final class CoinListViewModel: ObservableObject {
    
    // MARK: Properties
    @Published public private(set) var coins: [Coin] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: NetworkError?
    @Published public private(set) var isConnected = true
    @Published public private(set) var connectionType: NetworkMonitor.ConnectionType = .unknown
    @Published public private(set) var lastUpdated: Date?
    
    private let fetchCoinsUseCase: FetchCoinsUseCase
    private let networkMonitor: NetworkMonitor
    private var monitoringTask: Task<Void, Never>?
    
    private var isAutoRefreshEnabled = true
    private var previousConnectionState = true
    
    // MARK: INIT
    
    init(
        fetchCoinsUseCase: FetchCoinsUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.fetchCoinsUseCase = fetchCoinsUseCase
        self.networkMonitor = networkMonitor
        setupNetworkMonitoring()
    }
    
   func loadCoins(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        var loadError: NetworkError?
        
        do {
            let fetchedCoins = try await fetchCoinsUseCase.execute(forceRefresh: forceRefresh)
            await MainActor.run {
                self.coins = fetchedCoins
                self.lastUpdated = Date()
            }
        } catch let networkError as NetworkError {
            loadError = networkError
        } catch {
            loadError = .unknown(error)
        }
        
        await MainActor.run {
            self.error = loadError
            self.isLoading = false
        }
    }
    
   private func loadDetailsCoind(forceRefresh: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        var loadError: NetworkError?
        
        do {
            let fetchedCoins = try await fetchCoinsUseCase.executDetails(forceRefresh: forceRefresh)
            await MainActor.run {
                self.coins = fetchedCoins
            }
        } catch let networkError as NetworkError {
            loadError = networkError
        } catch {
            loadError = .unknown(error)
        }
        
        await MainActor.run {
            self.error = loadError
            self.isLoading = false
        }
    }
    
    func refresh() async {
        await loadCoins(forceRefresh: true)
    }
    
    func fetchDetails() async {
        await loadDetailsCoind(forceRefresh: true)
    }
    
    func clearError() {
        error = nil
    }
    
    func setAutoRefreshEnabled(_ enabled: Bool) {
        isAutoRefreshEnabled = enabled
    }
    
    private func setupNetworkMonitoring() {
        monitoringTask = Task { [weak self] in
            guard let self = self else { return }
            
            for await status in self.networkMonitor.connectionUpdates {
                self.handleConnectionChange(status)
            }
        }
    }
    
    @MainActor
    private func handleConnectionChange(_ status: NetworkMonitor.ConnectionStatus) {
        let wasConnected = self.isConnected
        self.isConnected = status.isConnected
        self.connectionType = status.connectionType
        
        // ✅auto-refresh
        if isAutoRefreshEnabled {
            if !wasConnected && status.isConnected {
                // auto-refresh when back net
                handleReconnection()
            } else if wasConnected && !status.isConnected {
                // if dont have net - showt disconnected
                handleDisconnection()
            }
        }
    }
    
    @MainActor
    private func handleReconnection() {
        print("📡 Internet connection restored - performing auto-refresh")
        
        Task {
            do {
                if let refreshedCoins = try await self.fetchCoinsUseCase.executeAutoRefresh() {
                    await MainActor.run {
                        self.coins = refreshedCoins
                        self.lastUpdated = Date()
                        self.error = nil
                        print("✅ Auto-refresh completed successfully")
                    }
                } else {
                    print("ℹ️ No auto-refresh needed - data is still fresh")
                }
            } catch {
                await MainActor.run {
                    self.error = error as? NetworkError ?? .unknown(error)
                    print("❌ Auto-refresh failed: \(error)")
                }
            }
        }
    }
    
    @MainActor
    private func handleDisconnection() {
        print("📡 Internet connection lost")
        
        isConnected = false
        error = .noInternetConnection
        setAutoRefreshEnabled(false)
        
        Task {
            var delay: Double = 1
            
            while !isConnected {
                print("⏳ Retrying in \(delay) seconds…")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                
                if networkMonitor.isConnected {
                    print("✅ Network restored during retry loop")
                    handleReconnection()
                    break
                }
                
                // exponential-backoff
                delay = min(delay * 2, 30)
            }
        }
    }
    
    
    deinit {
        monitoringTask?.cancel()
    }
}

