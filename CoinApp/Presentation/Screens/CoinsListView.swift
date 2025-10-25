//
//  ContentView.swift
//  CoinApp
//
//  Created by Mohammad on 10/21/25.
//

import SwiftUI
import Data
import Domain
import Core

// MARK: - Views
struct CoinListView: View {
     
    // MARK: Peroperties
    
    @StateObject private var viewModel: CoinListViewModel
    @State private var showLastUpdated = false
    
    init(viewModel: CoinListViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DIContainer.shared.makeCoinListViewModel())
    }
    
    // MARK: BODY
    var body: some View {
        mainView
    }
    
    // MARK: Wrapped View
    
    private var mainView: some View {
        NavigationView {
            middleView
            .navigationTitle("Cryptocurrencies")
            .toolbar {
                toolbarItem
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.clearError() }
                Button("Retry") { Task { await viewModel.loadCoins() } }
            } message: {
                Text(viewModel.error?.errorDescription ?? "Unknown error")
            }
        }
        .task {
            await viewModel.loadCoins()
//            await viewModel.fetchDetails()
        }

    }
    
    private var middleView: some View {
        ZStack {
            if viewModel.coins.isEmpty && viewModel.isLoading {
                progressView
            } else {
                coinListView
            }
        }
    }
    
    private var textFeildSearch: some View {
        TextField("Searching coin", text: $viewModel.searchText)
            .dynamicTypeSize(.xSmall ... .xxLarge)
    }
    
    private var progressView: some View {
        ProgressView("Loading coins...")
    }
    
    private var coinListView: some View {
        List {
            if let lastUpdated = viewModel.lastUpdated {
                Section {
                    textFeildSearch
                }
                Section {
                    HStack {
                        Image(systemName: "clock")
                        Text("Last updated: \(lastUpdated, style: .relative) ago")
                        Spacer()
                        if !viewModel.isConnected {
                            Image(systemName: "wifi.slash")
                                .foregroundColor(.orange)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            ForEach(viewModel.filterCoins, id: \.id) { coin in
                CoinRowView(coin: coin)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if viewModel.lastUpdated != nil {
                Button(action: { showLastUpdated.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack {
                if !viewModel.isConnected {
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.orange)
                        .help("Offline - using cached data")
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                Button(action: {
                    Task {
                        await viewModel.refresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

#Preview("coinapp") {
    
    CoinListView()
}
