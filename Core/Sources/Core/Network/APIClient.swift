//
//  APIClient.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

// Data/Network/APIClient.swift
import Foundation
import Security
import OSLog
import Network

// MARK: - API Client
public actor APIClient {
    private let session: URLSession
    private let configuration: APIConfiguration
    private let retryManager: RetryManager
    private let jsonDecoder: JSONDecoder
    
    public init(
        configuration: APIConfiguration = .default,
        retryConfiguration: RetryConfiguration = .default
    ) {
        self.configuration = configuration
        self.retryManager = RetryManager(configuration: retryConfiguration)
        
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .iso8601
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 15
        sessionConfig.timeoutIntervalForResource = 15
        sessionConfig.waitsForConnectivity = true
        sessionConfig.httpMaximumConnectionsPerHost = 4
        
        let sslPinningDelegate = SSLPinningDelegate()
        self.session = URLSession(
            configuration: sessionConfig,
            delegate: sslPinningDelegate.hasPinnedCertificates ? sslPinningDelegate : nil,
            delegateQueue: nil
        )
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try buildRequest(for: endpoint)
        return try await executeWithRetry(request: request)
    }
    
    private func buildRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        if let apiKey = configuration.apiKey {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func executeWithRetry<T: Decodable>(request: URLRequest) async throws -> T {
        await retryManager.reset()
        
        while await retryManager.shouldRetry() {
            do {
                let (data, response) = try await session.data(for: request)
                try validateResponse(response)
                let decoded = try await decodeResponse(data: data) as T
                await retryManager.reset()
                return decoded
                
            } catch {
                let delay = await retryManager.getNextDelay()
                await retryManager.incrementAttempt()
                
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet, .networkConnectionLost:
                        throw NetworkError.noInternetConnection
                    case .cancelled:
                        throw NetworkError.cancelled
                    default:
                        break
                    }
                }
                
                guard await retryManager.shouldRetry() else {
                    throw NetworkError.maxRetriesExceeded
                }
                
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        throw NetworkError.maxRetriesExceeded
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.failedResponse(statusCode: httpResponse.statusCode)
        }
    }
    
    private func decodeResponse<T: Decodable>(data: Data) async throws -> T {
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
