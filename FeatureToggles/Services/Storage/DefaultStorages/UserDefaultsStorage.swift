import Foundation

private enum Constants {
    static let defaultStorageName = "FTSDK:Storage:FeatureFlags"
    static let keyFlagsHash = "FTSDK:Storage:FlagsHash"
}

final class UserDefaultsStorage {
    
    // MARK: - Properties
    
    private let userDefaults = UserDefaults.standard
    private let cryptService = CryptService()
    
    private var flags: [SDKFeatureFlag] = []
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
           let flags = try? JSONDecoder().decode([SDKFeatureFlag].self, from: decryptedData) {
            self.flags = flags
        }
        
        let localFlags = appFlags
            .filter { appFlag in
                !flags.contains { appFlag.uid == $0.name }
            }.map {
                SDKFeatureFlag(name: $0.uid,
                               description: $0.description,
                               localState: $0.defaultState)
            }
        
        if !localFlags.isEmpty {
            save(flags: flags + localFlags)
        }
    }
    
}

// MARK: - FeatureTogglesStorage

extension UserDefaultsStorage: FeatureTogglesStorage {
    
    func save(remoteFlags: [SDKFeatureFlag]) {
        if !appFlags.isEmpty {
            for index in 0 ..< flags.count {
                guard let remoteFlag = remoteFlags.first(where: { $0.name == flags[index].name }) else {
                    flags[index].isOverride = true
                    return
                }
                flags[index].description = remoteFlag.description
                flags[index].remoteState = remoteFlag.remoteState
                flags[index].group = remoteFlag.group
            }
        } else {
            remoteFlags.forEach { remoteFlag in
                guard let index = flags.firstIndex(where: { $0.name == remoteFlag.name }) else {
                    flags.append(remoteFlag)
                    return
                }
                flags[index].description = remoteFlag.description
                flags[index].remoteState = remoteFlag.remoteState
                flags[index].group = remoteFlag.group
            }
        }
        
        save(flags: flags)
        
        FeatureTogglesLoggingService.shared.log(message: "Remote feature flags were saved.")
    }
    
    func save() {
        if let encodedData = try? JSONEncoder().encode(flags),
           let encryptedData = cryptService?.encrypt(encodedData) {
            userDefaults.set(encryptedData, forKey: Constants.defaultStorageName)
        }
             
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(flags: [SDKFeatureFlag]) {
        if let encodedData = try? JSONEncoder().encode(flags),
           let encryptedData = cryptService?.encrypt(encodedData) {
            userDefaults.set(encryptedData, forKey: Constants.defaultStorageName)
        }
        
        self.flags = flags
             
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(hash: String) {
        userDefaults.set(hash, forKey: Constants.keyFlagsHash)
        
        FeatureTogglesLoggingService.shared.log(message: "Hash was saved.")
    }
    
    func getByName(name: String) -> SDKFeatureFlag? {
        return flags.first { $0.name == name }
    }
    
    func getHash() -> String? {
        return userDefaults.string(forKey: Constants.keyFlagsHash)
    }
    
    func getFlags() -> [SDKFeatureFlag] {
        return flags
    }
    
    func changeLocalState(name: String, value: Bool) {
        guard let index = flags.firstIndex(where: { $0.name == name }) else { return }
        flags[index].localState = value
        save()
    }
    
    func changeOverrideState(name: String, value: Bool) {
        guard let index = flags.firstIndex(where: { $0.name == name }) else { return }
        flags[index].isOverride = value
        save()
    }
    
    func clear() {
        userDefaults.set(nil, forKey: Constants.defaultStorageName)
        userDefaults.set(nil, forKey: Constants.keyFlagsHash)
        flags = []
        
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
    func resetToDefaultValues() {
        guard !appFlags.isEmpty else {
            for index in 0 ..< flags.count {
                flags[index].localState = flags[index].remoteState ?? false
                flags[index].isOverride = false
            }
            save()
            return
        }
        
        for index in 0 ..< flags.count {
            guard let localFlag = appFlags.first(where: { $0.uid == flags[index].name }) else { return }
            flags[index].localState = localFlag.defaultState
            flags[index].isOverride = flags[index].isLocal
        }
        
        save()
    }
    
}