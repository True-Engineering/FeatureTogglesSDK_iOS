import Foundation

private enum Constants {
    static let defaultPreferenceName = "FTSDK:Storage:SharedPreferences"
    static let keyFlagsHash = "FTSDK:Storage:FlagsHash"
}

final class UserDefaultsPreferencesStorage {
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let cryptService = CryptService()
    
    private var flags: [String: SDKFlag] = [:]
    
    // MARK: - Init
    
    init() {
        if let data = UserDefaults.standard.object(forKey: Constants.defaultPreferenceName) as? Data,
           let decryptedData = cryptService?.decrypt(data),
           let flags = try? JSONDecoder().decode([String: SDKFlag].self, from: decryptedData) {
            self.flags = flags
        }
    }
}

// MARK: - FeatureTogglesStorage

extension UserDefaultsPreferencesStorage: FeatureTogglesStorage {
    
    func save(flags: [SDKFlag]) {
        var dictionary: [String: SDKFlag] = [:]
        flags.forEach {
            dictionary[$0.name] = $0
        }
        if let encodedData = try? JSONEncoder().encode(dictionary),
           let encryptedData = cryptService?.encrypt(encodedData) {
            userDefaults.set(encryptedData, forKey: Constants.defaultPreferenceName)
        }
        self.flags = dictionary
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(hash: String) {
        userDefaults.set(hash, forKey: Constants.keyFlagsHash)
        FeatureTogglesLoggingService.shared.log(message: "Hash was saved.")
    }
    
    func getByName(name: String) -> SDKFlag? {
        return flags[name]
    }
    
    func getHash() -> String? {
        return userDefaults.string(forKey: Constants.keyFlagsHash)
    }
    
    func getFlags() -> [SDKFlag] {
        return flags.map { $0.value }
    }
    
    func clear() {
        userDefaults.set(nil, forKey: Constants.defaultPreferenceName)
        userDefaults.set(nil, forKey: Constants.keyFlagsHash)
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
}
