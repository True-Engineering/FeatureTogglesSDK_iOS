import Foundation

enum KeychainKey: String, CaseIterable {
    
    // Crypt Keys
    case cryptKey
    case cryptIv
    
    var keyValue: String {
        return "__FF_SDK_keychain_" + rawValue
    }
    
}

final class KeychainService {
    
    private let keychain = KeychainSwift()
    
    func set(key: KeychainKey, value: String) {
        keychain.set(value,
                     forKey: key.keyValue,
                     withAccess: .accessibleAfterFirstUnlock)
    }
    
    func get(for key: KeychainKey) -> String? {
        return keychain.get(key.keyValue)
    }
    
    func delete(for key: KeychainKey) {
        keychain.delete(key.keyValue)
    }
    
    func clear() {
        KeychainKey.allCases.forEach { delete(for: $0) }
    }
    
}

// MARK: - Private methods

extension KeychainService {
    
    private func getData(for key: KeychainKey) -> Data? {
        return keychain.getData(key.keyValue)
    }
    
}

// MARK: - Crypt

extension KeychainService {
    
    var cryptData: (key: Data, iv: Data)? {
        guard let key = getData(for: .cryptKey),
              let iv = getData(for: .cryptIv) else {
            return nil
        }
        return (key, iv)
    }
    
    func saveCrypt(key: String, iv: String) {
        set(key: .cryptKey, value: key)
        set(key: .cryptIv, value: iv)
    }
    
}
