//
//  CoinRowView.swift
//  CoinApp
//
//  Created by Mohammad on 10/21/25.
//

import SwiftUI
import Domain

struct CoinRowView: View {
    let coin: Coin
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: coin.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                case .failure:
                    Color.gray
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(coin.currentPrice, format: .currency(code: "USD"))
                    .font(.headline)
                
                if let change = coin.priceChangePercentage24h {
                    HStack(spacing: 2) {
                        Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                        Text(change, format: .percent.precision(.fractionLength(2)))
                    }
                    .font(.caption)
                    .foregroundColor(change >= 0 ? .green : .red)
                }
            }
        }
    }
}
