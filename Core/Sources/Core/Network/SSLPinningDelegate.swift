//
//  SSLPinningDelegate.swift
//  Core
//
//  Created by Mohammad on 10/21/25.
//

// Data/Network/SSLPinningDelegate.swift
import Foundation
import Security

// MARK: - SSL Pinning
public final class SSLPinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data]
    
    public var hasPinnedCertificates: Bool {
        !pinnedCertificates.isEmpty
    }
    
    public override init() {
        self.pinnedCertificates = []
        super.init()
    }
    
    public init(pinnedCertificates: [Data]) {
        self.pinnedCertificates = pinnedCertificates
        super.init()
    }
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        guard !pinnedCertificates.isEmpty else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        for index in 0..<certificateCount {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, index),
                  let certificateData = SecCertificateCopyData(certificate) as Data?,
                  pinnedCertificates.contains(certificateData) else { continue }
            
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
