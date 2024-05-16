import Foundation

private enum Constants {
    static let defaultStorageName = "FTSDK:Storage:FeatureFlags"
    static let keyFlagsHash = "FTSDK:Storage:FlagsHash"
}

final class UserDefaultsStorage {
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let cryptService = CryptService()
    
    private var flags: [String: SDKFeatureFlag] = [:]
    private var appFlags: [any FeatureFlagsEnum]
    
    // MARK: - Init
    
    init(appFlags: [any FeatureFlagsEnum]) {
        self.appFlags = appFlags
        
        fetchFlagsFromStorage(appFlags: appFlags)
    }
    
}

// MARK: - Private methods

extension UserDefaultsStorage {
    
    private func fetchFlagsFromStorage(appFlags: [any FeatureFlagsEnum] = []) {
        if let data = UserDefaults.standard.object(forKey: Constants.defaultStorageName) as? Data,
           let decryptedData = cryptService?.decrypt(data),
           let flags = try? JSONDecoder().decode([String: SDKFeatureFlag].self, from: decryptedData) {
            self.flags = flags
        }
        
        let localFlags = appFlags
            .filter { appFlag in
                !flags.keys.contains { appFlag.uid == $0 }
            }.map {
                SDKFeatureFlag(name: $0.uid,
                               description: $0.description,
                               localState: $0.defaultState)
            }
        
        if !localFlags.isEmpty {
            save(flags: flags.values + localFlags)
        }
    }
    
    private func save(dictionary: [String: SDKFeatureFlag]) {
        if let encodedData = try? JSONEncoder().encode(dictionary),
           let encryptedData = cryptService?.encrypt(encodedData) {
            userDefaults.set(encryptedData, forKey: Constants.defaultStorageName)
        }
    }
    
}

// MARK: - FeatureTogglesStorage

extension UserDefaultsStorage: FeatureTogglesStorage {
    
    func save(remoteFlags: [SDKFeatureFlag]) {
        if !appFlags.isEmpty {
            flags.keys.forEach { key in
                guard let remoteFlag = remoteFlags.first(where: { $0.name == key }) else {
                    flags[key]?.isOverride = true
                    return
                }
                flags[key]?.description = remoteFlag.description
                flags[key]?.remoteState = remoteFlag.remoteState
                flags[key]?.group = remoteFlag.group
            }
        } else {
            var dictionary: [String: SDKFeatureFlag] = [:]
            remoteFlags.forEach { dictionary[$0.name] = $0 }
            
            dictionary.keys.forEach { key in
                guard flags.keys.contains(where: { $0 == key }) else {
                    flags[key] = dictionary[key]
                    return
                }
                flags[key]?.description = dictionary[key]?.description ?? ""
                flags[key]?.remoteState = dictionary[key]?.remoteState ?? false
                flags[key]?.group = dictionary[key]?.group
            }
        }
        
        save(dictionary: flags)
        
        FeatureTogglesLoggingService.shared.log(message: "Remote feature flags were saved.")
    }
    
    func save(flags: [SDKFeatureFlag]) {
        var dictionary: [String: SDKFeatureFlag] = [:]
        flags.forEach { dictionary[$0.name] = $0 }
        
        self.flags = dictionary
        save(dictionary: dictionary)
             
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(hash: String) {
        userDefaults.set(hash, forKey: Constants.keyFlagsHash)
        
        FeatureTogglesLoggingService.shared.log(message: "Hash was saved.")
    }
    
    func getByName(name: String) -> SDKFeatureFlag? {
        return flags[name]
    }
    
    func getHash() -> String? {
        return userDefaults.string(forKey: Constants.keyFlagsHash)
    }
    
    func getFlags() -> [SDKFeatureFlag] {
        return flags.map { $0.value }
    }
    
    func changeLocalState(name: String, value: Bool) {
        flags[name]?.localState = value
        save(dictionary: flags)
    }
    
    func changeOverrideState(name: String, value: Bool) {
        flags[name]?.isOverride = value
        save(dictionary: flags)
    }
    
    func clear() {
        userDefaults.set(nil, forKey: Constants.defaultStorageName)
        userDefaults.set(nil, forKey: Constants.keyFlagsHash)
        
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
    func resetToDefaultValues() {
        guard !appFlags.isEmpty else {
            flags.keys.forEach { key in
                let remoteState = flags[key]?.remoteState ?? false
                flags[key]?.localState = remoteState
                flags[key]?.isOverride = false
            }
            save(dictionary: flags)
            return
        }
        
        flags.keys.forEach { key in
            guard let localFlag = appFlags.first(where: { $0.uid == key }) else { return }
            let isLocal = flags[key]?.isLocal ?? false
            flags[key]?.localState = localFlag.defaultState
            flags[key]?.isOverride = isLocal
        }
        
        save(dictionary: flags)
    }
    
}
