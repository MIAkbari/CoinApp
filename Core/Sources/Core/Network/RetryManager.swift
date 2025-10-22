//
//  File.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

import Foundation

public struct RetryConfiguration: Sendable {
    public let maxRetryCount: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let backoffMultiplier: Double
    
    public static let `default` = RetryConfiguration(
        maxRetryCount: 3,
        baseDelay: 1.0,
        maxDelay: 30.0,
        backoffMultiplier: 2.0
    )
}


// MARK: - Retry Manager
public actor RetryManager {
    private var currentAttempt = 0
    private let configuration: RetryConfiguration
    
    public init(configuration: RetryConfiguration = .default) {
        self.configuration = configuration
    }
    
    public func shouldRetry() -> Bool {
        currentAttempt < configuration.maxRetryCount
    }
    
    public func getNextDelay() -> TimeInterval {
        guard currentAttempt > 0 else { return 0 }
        let delay = configuration.baseDelay * pow(configuration.backoffMultiplier, Double(currentAttempt - 1))
        return min(delay, configuration.maxDelay)
    }
    
    public func incrementAttempt() {
        currentAttempt += 1
    }
    
    public func reset() {
        currentAttempt = 0
    }
}
