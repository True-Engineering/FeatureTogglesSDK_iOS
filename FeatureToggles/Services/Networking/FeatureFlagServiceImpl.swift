import Foundation
import CommonCrypto

internal class FeatureFlagServiceImpl {
    
    // MARK: - Properties
    
    private var endpoint: String
    private var headers: [String: String] = [:]
    private var session: URLSession
    private let delegateHandler: URLSessionDelegateHandler
    
    // MARK: - Init
    
    init(endpoint: String,
         headers: [String: String]) {
        self.endpoint = endpoint
        self.headers = headers
        self.delegateHandler = URLSessionDelegateHandler()
        
        session = URLSession(configuration: .default, delegate: delegateHandler, delegateQueue: nil)
    }
    
    // MARK: - Deinit
    
    deinit {
        session.invalidateAndCancel()
    }
    
}

// MARK: - FeatureFlagService

extension FeatureFlagServiceImpl: FeatureFlagService {
    
    func loadFeatureToggles(completion: @escaping ((SDKFeatureFlagsWithHash?, Int?) -> Void)) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                if let error {
                    FeatureTogglesLoggingService.shared.log(message: "[Error] \(error.localizedDescription)")
                    completion(nil, nil)
                }
                return
            }
            
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                FeatureTogglesLoggingService.shared.log(message: "[Error] Status code was \(httpResponse.statusCode), but expected 2xx")
                completion(nil, httpResponse.statusCode)
                return
            }
            
            guard let featureFlagsWithHash = try? JSONDecoder().decode(FeatureFlagsWithHash.self, from: data) else {
                FeatureTogglesLoggingService.shared.log(message: "[Error] Can't parse response to expected result")
                completion(nil, nil)
                return
            }
            
            let featureFlags = featureFlagsWithHash.featureFlags.map { SDKFeatureFlag(name: $0.key,
                                                                                      description: $0.value.description,
                                                                                      group: $0.value.group,
                                                                                      isEnabled: $0.value.enable) }
            let hash = featureFlagsWithHash.featureFlagsHash
            
            completion(SDKFeatureFlagsWithHash(flags: featureFlags, hash: hash), nil)
        }
        
        task.resume()
    }
    
}

// MARK: - URLSessionDelegateHandler

final private class URLSessionDelegateHandler: NSObject, URLSessionDelegate {
    
    private let interceptorService: InterceptorService
    
    init(interceptorService: InterceptorService = .shared) {
        self.interceptorService = interceptorService
    }
    
    private var rsa2048Asn1Header: [UInt8] {
        return [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
            0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]
    }
    
    private func sha256(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        keyWithHeader.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress!, CC_LONG(buffer.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.host == interceptorService.host,
              (InterceptorService.shared.publicKeyHash != nil || InterceptorService.shared.certificates != nil) else {
            completionHandler(.useCredential, nil)
            return
        }
        
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              SecTrustGetCertificateCount(serverTrust) > 0 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            guard interceptorService.publicKeyHash != nil else {
                checkCertificate(certificate: certificate, trust: serverTrust, completionHandler: completionHandler)
                return
            }
            
            checkKey(certificate: certificate, trust: serverTrust, completionHandler: completionHandler)
        }
    }
    
    private func checkCertificate(certificate: SecCertificate,
                                  trust: SecTrust,
                                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let certificates = interceptorService.certificates else {
            completionHandler(.useCredential, nil)
            return
        }
        
        let data = SecCertificateCopyData(certificate) as Data
                        
        if certificates.contains(data) == true {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    private func checkKey(certificate: SecCertificate,
                          trust: SecTrust,
                          completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Server public key
        let serverPublicKey = SecCertificateCopyKey(certificate)
        
        // Server public key data
        let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil)!
        let data: Data = serverPublicKeyData as Data
        
        // Server public key hash
        let serverHashKey = sha256(data: data)
        
        if serverHashKey == interceptorService.publicKeyHash {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
}
