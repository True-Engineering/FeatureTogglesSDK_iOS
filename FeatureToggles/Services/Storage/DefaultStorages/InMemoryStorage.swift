import Foundation

final class InMemoryStorage {
    
    // MARK: - Properties
    
    private var flagsStorage: [String: SDKFeatureFlag] = [:]
    private var flagsHash: String?
    private var appFlags: [any FeatureFlagsEnum]
    
    init(appFlags: [any FeatureFlagsEnum]) {
        self.appFlags = appFlags
        
        fetchFlagsFromStorage(appFlags: appFlags)
    }
    
}


// MARK: - Private methods

extension InMemoryStorage {
    
    private func fetchFlagsFromStorage(appFlags: [any FeatureFlagsEnum] = []) {
        guard !appFlags.isEmpty else { return }
        
        let localFlags = appFlags
            .filter { appFlag in
                !flagsStorage.keys.contains { appFlag.uid == $0 }
            }.map {
                SDKFeatureFlag(name: $0.uid,
                               description: $0.description,
                               localState: $0.defaultState)
            }
        
        save(flags: flagsStorage.values + localFlags)
    }
    
}

// MARK: - FeatureTogglesStorage

extension InMemoryStorage: FeatureTogglesStorage {
    
    func save(remoteFlags: [SDKFeatureFlag]) {
        if !appFlags.isEmpty {
            flagsStorage.keys.forEach { key in
                guard let remoteFlag = remoteFlags.first(where: { $0.name == key }) else {
                    flagsStorage[key]?.isOverride = true
                    return
                }
                flagsStorage[key]?.description = remoteFlag.description
                flagsStorage[key]?.remoteState = remoteFlag.remoteState
                flagsStorage[key]?.group = remoteFlag.group
            }
        } else {
            var dictionary: [String: SDKFeatureFlag] = [:]
            remoteFlags.forEach { dictionary[$0.name] = $0 }
            
            dictionary.keys.forEach { key in
                guard flagsStorage.keys.contains(where: { $0 == key }) else {
                    flagsStorage[key] = dictionary[key]
                    return
                }
                flagsStorage[key]?.description = dictionary[key]?.description ?? ""
                flagsStorage[key]?.remoteState = dictionary[key]?.remoteState ?? false
                flagsStorage[key]?.group = dictionary[key]?.group
            }
        }
    }
    
    func save(flags: [SDKFeatureFlag]) {
        var dictionary: [String: SDKFeatureFlag] = [:]
        flags.forEach { dictionary[$0.name] = $0 }
        flagsStorage = dictionary
        
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(hash: String) {
        flagsHash = hash
        FeatureTogglesLoggingService.shared.log(message: "Hash was saved.")
    }
    
    func getHash() -> String? {
        return flagsHash
    }
    
    func getByName(name: String) -> SDKFeatureFlag? {
        return flagsStorage[name]
    }
    
    func getFlags() -> [SDKFeatureFlag] {
        return flagsStorage.map { $0.value }
    }
    
    func changeLocalState(name: String, value: Bool) {
        flagsStorage[name]?.localState = value
    }
    
    func changeOverrideState(name: String, value: Bool) {
        flagsStorage[name]?.isOverride = value
    }
    
    func clear() {
        flagsHash = nil
        flagsStorage = [:]
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
    func resetToDefaultValues() {
        guard !appFlags.isEmpty else {
            flagsStorage.keys.forEach { key in
                let remoteState = flagsStorage[key]?.remoteState ?? false
                flagsStorage[key]?.localState = remoteState
                flagsStorage[key]?.isOverride = false
            }
            return
        }
        
        flagsStorage.keys.forEach { key in
            guard let localFlag = appFlags.first(where: { $0.uid == key }) else { return }
            flagsStorage[key]?.localState = localFlag.defaultState
            flagsStorage[key]?.isOverride = false
        }
    }
    
}
