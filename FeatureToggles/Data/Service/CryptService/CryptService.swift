import Foundation
import CommonCrypto

struct CryptService {
    
    // MARK: - Properties
    
    private let keychain = KeychainService()
    
    private let key: Data
    private let iv: Data
    
    private static var newCryptKeys: (key: String, iv: String) {
        let key = UUID().uuidString.replacingOccurrences(of: "-", with: "").substring(to: kCCKeySizeAES256)
        let iv = UUID().uuidString.replacingOccurrences(of: "-", with: "").substring(to: kCCBlockSizeAES128)
        
        return (key, iv)
    }
    
    // MARK: - Init
    
    init?() {
        guard let cryptData = keychain.cryptData else {
            let keys = CryptService.newCryptKeys
            keychain.saveCrypt(key: keys.key, iv: keys.iv)
            
            if let cryptData = keychain.cryptData {
                self.key = cryptData.key
                self.iv  = cryptData.iv
                return
            }
            
            return nil
        }
        
        self.key = cryptData.key
        self.iv  = cryptData.iv
    }
}

// MARK: - Intenral methods

extension CryptService {
    
    func encrypt(_ data: Data) -> Data? {
        return crypt(data: data, option: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ data: Data?) -> Data? {
        return crypt(data: data, option: CCOperation(kCCDecrypt))
    }
    
}

// MARK: - Private methods

extension CryptService {
    
    private func crypt(data: Data?,
                       option: CCOperation,
                       key: Data? = nil,
                       iv: Data? = nil) -> Data? {
        guard let data else { return nil }
        let key = key ?? self.key
        let iv = iv ?? self.iv
        
        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData = Data(count: cryptLength)
        
        let keyLength = key.count
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var bytesLength = Int(0)
        
        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                        CCCrypt(option,
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes.baseAddress,
                                keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress,
                                data.count,
                                cryptBytes.baseAddress,
                                cryptLength,
                                &bytesLength)
                    }
                }
            }
        }
        
        guard UInt32(status) == UInt32(kCCSuccess) else {
            return nil
        }
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}
