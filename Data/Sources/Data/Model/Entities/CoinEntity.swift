//
//  CoinEntity.swift
//  Data
//
//  Created by Mohammad on 10/22/25.
//


import SwiftData
import Foundation

// MARK: - SwiftData Entity
@Model
public final class CoinEntity {
    @Attribute(.unique) public var id: String
    public var symbol: String
    public var name: String
    public var image: String
    public var currentPrice: Double
    public var priceChangePercentage24h: Double?
    public var marketCap: Double?
    public var marketCapRank: Int?
    public var lastUpdated: Date?
    
    public init(
        id: String,
        symbol: String,
        name: String,
        image: String,
        currentPrice: Double,
        priceChangePercentage24h: Double? = nil,
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