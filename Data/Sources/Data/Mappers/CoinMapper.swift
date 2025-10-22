//
//  File.swift
//  Data
//
//  Created by Mohammad on 10/21/25.
//

// Data/Mappers/CoinMapper.swift
import Foundation
import Domain


// MARK: - Mappers
public enum CoinMapper {
    public static func toDomain(_ dto: CoinDTO) -> Coin {
        Coin(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            image: dto.image,
            currentPrice: dto.currentPrice,
            priceChangePercentage24h: dto.priceChangePercentage24h,
            marketCap: dto.marketCap,
            marketCapRank: dto.marketCapRank,
            lastUpdated: ISO8601DateFormatter().date(from: dto.lastUpdated ?? "")
        )
    }
    
    public static func toDomain(_ data: CoinData) -> Coin {
        Coin(
            id: data.id,
            symbol: data.symbol,
            name: data.name,
            image: data.image,
            currentPrice: data.currentPrice,
            priceChangePercentage24h: data.priceChangePercentage24h,
            marketCap: data.marketCap,
            marketCapRank: data.marketCapRank,
            lastUpdated: data.lastUpdated
        )
    }
    
    public static func toData(_ dto: CoinDTO) -> CoinData {
        CoinData(
            id: dto.id,
            symbol: dto.symbol,
            name: dto.name,
            image: dto.image,
            currentPrice: dto.currentPrice,
            priceChangePercentage24h: dto.priceChangePercentage24h,
            marketCap: dto.marketCap,
            marketCapRank: dto.marketCapRank,
            lastUpdated: ISO8601DateFormatter().date(from: dto.lastUpdated ?? "")
        )
    }
}
