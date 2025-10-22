//
//  File.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

// Core/Network/NetworkMonitor.swift
import Network
import Combine

// MARK: - Network Monitor (Fixed Version)
@MainActor
public class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    
    @Published public private(set) var isConnected = true
    @Published public private(set) var connectionType: ConnectionType = .unknown
    
    private final class ContinuationBox: Sendable {
        let continuation: AsyncStream<ConnectionStatus>.Continuation
        
        init(continuation: AsyncStream<ConnectionStatus>.Continuation) {
            self.continuation = continuation
        }
    }
    
    private var continuations: [ContinuationBox] = []
    
    public enum ConnectionType: String, CaseIterable, Sendable, CustomStringConvertible {
        case wifi, cellular, ethernet, unknown
        public var description: String { rawValue.capitalized }
    }
    
    public struct ConnectionStatus: Sendable {
        public let isConnected: Bool
        public let connectionType: ConnectionType
        
        public init(isConnected: Bool, connectionType: ConnectionType) {
            self.isConnected = isConnected
            self.connectionType = connectionType
        }
    }
    
    public var connectionStatus: ConnectionStatus {
        ConnectionStatus(isConnected: isConnected, connectionType: connectionType)
    }
    
    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                let newIsConnected = path.status == .satisfied
                let newConnectionType = self.determineConnectionType(path)
                
                guard self.isConnected != newIsConnected || self.connectionType != newConnectionType else { return }
                
                self.isConnected = newIsConnected
                self.connectionType = newConnectionType
                
                let status = ConnectionStatus(isConnected: newIsConnected, connectionType: newConnectionType)
                for box in self.continuations {
                    box.continuation.yield(status)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    public var connectionUpdates: AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            Task { @MainActor in
                let box = ContinuationBox(continuation: continuation)
                self.continuations.append(box)
                
                continuation.yield(ConnectionStatus(
                    isConnected: self.isConnected,
                    connectionType: self.connectionType
                ))
                
                continuation.onTermination = { [weak self] _ in
                    Task { @MainActor in
                        self?.continuations.removeAll { $0 === box }
                    }
                }
            }
        }
    }
    
    private func determineConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
    
    deinit {
        for box in continuations {
            box.continuation.finish()
        }
        monitor.cancel()
    }
}
