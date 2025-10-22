//
//  File.swift
//  Data
//
//  Created by Mohammad on 10/21/25.
//

// Data/DTOs/CoinDTO.swift
import Foundation

// MARK: - Data Transfer Objects
public struct CoinDTO: Codable, Sendable {
    public let id: String
    public let symbol: String
    public let name: String
    public let image: String
    public let currentPrice: Double
    public let marketCap: Double?
    public let marketCapRank: Int?
    public let priceChangePercentage24h: Double?
    public let lastUpdated: String?
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
    }
}
