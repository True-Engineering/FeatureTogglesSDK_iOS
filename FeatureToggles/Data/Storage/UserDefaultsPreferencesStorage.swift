import Foundation

private enum Constants {
    static let defaultPreferenceName = "FTSDK:Storage:SharedPreferences"
    static let keyFlagsHash = "FTSDK:Storage:FlagsHash"
}

class UserDefaultsPreferencesStorage: FeatureTogglesStorage {
    
    private let userDefaults = UserDefaults.standard
    private let cryptService = CryptService()
    
    private var flags: [String: SDKFlag] = [:]
    
    init() {
        if let data = UserDefaults.standard.object(forKey: Constants.defaultPreferenceName) as? Data,
           let decryptedData = cryptService?.decrypt(data),
           let flags = try? JSONDecoder().decode([String: SDKFlag].self, from: decryptedData) {
            self.flags = flags
        }
    }
    
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
    }
    
    func save(hash: String) {
        userDefaults.set(hash, forKey: Constants.keyFlagsHash)
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
    }
}
