//
//  File.swift
//  Data
//
//  Created by Mohammad on 10/21/25.
//

import Foundation
import SwiftData

public final class CoinLocalDataSource: CoinLocalDataSourceProtocol {
    private let modelContainer: ModelContainer
    
    public init() {
        do {
            self.modelContainer = try ModelContainer(for: CoinEntity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    @MainActor
    private func getContext() -> ModelContext {
        ModelContext(modelContainer)
    }
    
    public func saveCoins(_ coins: [CoinData]) async throws {
        try await MainActor.run {
            let context = getContext()
            
            // Clear existing data
            let descriptor = FetchDescriptor<CoinEntity>()
            let existingCoins = try context.fetch(descriptor)
            for coin in existingCoins {
                context.delete(coin)
            }
            
            // Save new data
            for coinData in coins {
                let entity = CoinEntity(
                    id: coinData.id,
                    symbol: coinData.symbol,
                    name: coinData.name,
                    image: coinData.image,
                    currentPrice: coinData.currentPrice,
                    priceChangePercentage24h: coinData.priceChangePercentage24h,
                    marketCap: coinData.marketCap,
                    marketCapRank: coinData.marketCapRank,
                    lastUpdated: coinData.lastUpdated
                )
                context.insert(entity)
            }
            
            try context.save()
        }
    }
    
    public func getCoins() async throws -> [CoinData] {
        try await MainActor.run {
            let context = getContext()
            let descriptor = FetchDescriptor<CoinEntity>(
                sortBy: [SortDescriptor(\.marketCapRank)]
            )
            let entities = try context.fetch(descriptor)
            
            return entities.map { entity in
                CoinData(
                    id: entity.id,
                    symbol: entity.symbol,
                    name: entity.name,
                    image: entity.image,
                    currentPrice: entity.currentPrice,
                    priceChangePercentage24h: entity.priceChangePercentage24h,
                    marketCap: entity.marketCap,
                    marketCapRank: entity.marketCapRank,
                    lastUpdated: entity.lastUpdated
                )
            }
        }
    }
    
    public func clearCoins() async throws {
        try await MainActor.run {
            let context = getContext()
            let descriptor = FetchDescriptor<CoinEntity>()
            let allCoins = try context.fetch(descriptor)
            
            for coin in allCoins {
                context.delete(coin)
            }
            
            try context.save()
        }
    }
}
