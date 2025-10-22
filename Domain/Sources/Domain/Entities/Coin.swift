//
//  Coin.swift
//  Domain
//
//  Created by Mohammad on 10/21/25.
//

import Foundation

// MARK: - Domain Models
public struct Coin: Equatable, Identifiable, Sendable, Hashable {
    public let id: String
    public let symbol: String
    public let name: String
    public let image: String
    public let currentPrice: Double
    public let priceChangePercentage24h: Double?
    public let marketCap: Double?
    public let marketCapRank: Int?
    public let lastUpdated: Date?
    
    public init(
        id: String,
        symbol: String,
        name: String,
        image: String,
        currentPrice: Double,
        priceChangePercentage24h: Double?,
        marketCap: Double? = nil,
        marketCapRank: Int? = nil,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.priceChangePercentage24h = priceChangePercentage24h
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.lastUpdated = lastUpdated
    }
}
