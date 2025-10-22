//
//  NetworkError.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

// Core/Network/NetworkError.swift
import Foundation

// MARK: - Error Handling
public enum NetworkError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case failedResponse(statusCode: Int)
    case noInternetConnection
    case maxRetriesExceeded
    case cancelled
    case decodingError(Error)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .failedResponse(let code): return "Request failed with status code \(code)"
        case .noInternetConnection: return "No internet connection"
        case .maxRetriesExceeded: return "Maximum retry attempts exceeded"
        case .cancelled: return "Request cancelled"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .unknown(let error): return "Unknown error: \(error.localizedDescription)"
        }
    }
}
