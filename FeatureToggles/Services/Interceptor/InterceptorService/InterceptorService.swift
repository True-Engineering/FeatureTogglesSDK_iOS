import UIKit
import SwiftUI
import CommonCrypto

final class InterceptorService: NSObject {
    
    // MARK: - Singleton
    
    static let shared = InterceptorService()
    
    // MARK: - Properties
    
    internal var interceptorEnable = false
    internal var listenerEnable = false
    internal var swizzled = false
    
    var certificates: [Data]?
    var publicKeyHash: String?
    var host = ""
    
    let networkRequestInterceptor = NetworkRequestInterceptor()
    
    var ignore: Ignore = .disbaled
    
    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [Modifier]().retrieveFromDisk()
        return NetworkInterceptorConfig(modifiers: savedModifiers)
    }()
    
}

// MARK: - Private methods

extension InterceptorService {
    
    private func checkSwizzling() {
        if swizzled == false {
            self.networkRequestInterceptor.swizzleProtocolClasses()
            swizzled = true
        }
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

    
}

// MARK: - Public methods

extension InterceptorService {
    
    func startInterceptor() {
        self.networkRequestInterceptor.startInterceptor()
        checkSwizzling()
    }

    func stopInterceptor() {
        self.networkRequestInterceptor.stopInterceptor()
        checkSwizzling()
    }

    func startListener() {
        self.networkRequestInterceptor.startListener()
        checkSwizzling()
    }

    func stopListener() {
        self.networkRequestInterceptor.stopListener()
        checkSwizzling()
    }
    
    func modify(modifier: Modifier) {
        config.addModifier(modifier: modifier)
    }
    
    func modifiedList() -> [Modifier] {
        return config.modifiers
    }
    
    func removeModifier(at index: Int) {
        return config.removeModifier(at: index)
    }

}
