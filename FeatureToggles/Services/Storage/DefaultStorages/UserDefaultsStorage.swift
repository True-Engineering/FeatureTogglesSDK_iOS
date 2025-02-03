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
        // Create flags from FeatureFlagsEnum
        flags = appFlags.map {
            SDKFeatureFlag(name: $0.uid,
                           description: $0.description,
                           localState: $0.defaultState)
        }
        
        // Load flags from storage
        if let data = UserDefaults.standard.object(forKey: Constants.defaultStorageName) as? Data,
           let decryptedData = cryptService?.decrypt(data),
           let storedFlags = try? JSONDecoder().decode([SDKFeatureFlag].self, from: decryptedData) {
            if appFlags.isEmpty {
                flags = storedFlags
            } else {
                var shouldSave = appFlags.count != storedFlags.count
                storedFlags.forEach { flag in
                    guard let index = flags.firstIndex(where: { $0.name == flag.name }) else {
                        shouldSave = true
                        return
                    }
                    flags[index] = flag
                }
                
                if shouldSave {
                    save(flags: flags)
                }
            }
        }
    }
    
}

// MARK: - FeatureTogglesStorage

extension UserDefaultsStorage: FeatureTogglesStorage {
    
    func save(remoteFlags: [SDKFeatureFlag]) {
        if !appFlags.isEmpty {
            // If storage was cleared before
            if flags.isEmpty {
                fetchFlagsFromStorage(appFlags: appFlags)
            }
            
            for index in 0 ..< flags.count {
                guard let remoteFlag = remoteFlags.first(where: { $0.name == flags[index].name }) else {
                    flags[index].remoteState = nil
                    continue
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
            
            // Delete extra flags
            if flags.count != remoteFlags.count {
                flags.forEach { flag in
                    if !remoteFlags.contains(where: { flag.name == $0.name }),
                       let index = flags.firstIndex(where: { $0.id == flag.id }) {
                        flags.remove(at: index)
                    }
                }
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
    
    func changeUseLocalState(name: String, value: Bool) {
        guard let index = flags.firstIndex(where: { $0.name == name }) else { return }
        flags[index].useLocal = value
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
                flags[index].useLocal = false
            }
            save()
            return
        }
        
        for index in 0 ..< flags.count {
            guard let localFlag = appFlags.first(where: { $0.uid == flags[index].name }) else { continue }
            flags[index].localState = localFlag.defaultState
            flags[index].useLocal = false
        }
        
        save()
    }
    
}
