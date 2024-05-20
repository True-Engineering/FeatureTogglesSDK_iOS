import Foundation

final class InMemoryStorage {
    
    // MARK: - Properties
    
    private var flagsStorage: [SDKFeatureFlag] = []
    private var flagsHash: String?
    private var appFlags: [any FeatureFlagsEnum]
    
    init(appFlags: [any FeatureFlagsEnum]) {
        self.appFlags = appFlags
        fetchFlags(appFlags: appFlags)
    }
    
}


// MARK: - Private methods

extension InMemoryStorage {
    
    private func fetchFlags(appFlags: [any FeatureFlagsEnum] = []) {
        guard !appFlags.isEmpty else { return }
        
        flagsStorage = appFlags.map {
            SDKFeatureFlag(name: $0.uid,
                           description: $0.description,
                           localState: $0.defaultState)
        }
        
        save(flags: flagsStorage)
    }
    
}

// MARK: - FeatureTogglesStorage

extension InMemoryStorage: FeatureTogglesStorage {
    
    func save(remoteFlags: [SDKFeatureFlag]) {
        if !appFlags.isEmpty {
            // If storage was cleared before
            if flagsStorage.isEmpty {
                fetchFlags(appFlags: appFlags)
            }
            
            for index in 0 ..< flagsStorage.count {
                guard let remoteFlag = remoteFlags.first(where: { $0.name == flagsStorage[index].name }) else {
                    flagsStorage[index].isOverride = true
                    continue
                }
                flagsStorage[index].description = remoteFlag.description
                flagsStorage[index].remoteState = remoteFlag.remoteState
                flagsStorage[index].group = remoteFlag.group
            }
        } else {
            remoteFlags.forEach { remoteFlag in
                guard let index = flagsStorage.firstIndex(where: { $0.name == remoteFlag.name }) else {
                    flagsStorage.append(remoteFlag)
                    return
                }
                flagsStorage[index].description = remoteFlag.description
                flagsStorage[index].remoteState = remoteFlag.remoteState
                flagsStorage[index].group = remoteFlag.group
            }
            
            // Delete extra flags
            if flagsStorage.count != remoteFlags.count {
                flagsStorage.forEach { flag in
                    if !remoteFlags.contains(where: { flag.name == $0.name }),
                       let index = flagsStorage.firstIndex(where: { $0.id == flag.id }) {
                        flagsStorage.remove(at: index)
                    }
                }
            }
        }
    }
    
    func save(flags: [SDKFeatureFlag]) {
        flagsStorage = flags
        
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
        return flagsStorage.first { $0.name == name }
    }
    
    func getFlags() -> [SDKFeatureFlag] {
        return flagsStorage
    }
    
    func changeLocalState(name: String, value: Bool) {
        guard let index = flagsStorage.firstIndex(where: { $0.name == name }) else { return }
        flagsStorage[index].localState = value
    }
    
    func changeOverrideState(name: String, value: Bool) {
        guard let index = flagsStorage.firstIndex(where: { $0.name == name }) else { return }
        flagsStorage[index].isOverride = value
    }
    
    func clear() {
        flagsHash = nil
        flagsStorage = []
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
    func resetToDefaultValues() {
        guard !appFlags.isEmpty else {
            for index in 0 ..< flagsStorage.count {
                flagsStorage[index].localState = flagsStorage[index].remoteState ?? false
                flagsStorage[index].isOverride = false
            }
            return
        }
        
        for index in 0 ..< flagsStorage.count {
            guard let localFlag = appFlags.first(where: { $0.uid == flagsStorage[index].name }) else { continue }
            flagsStorage[index].localState = localFlag.defaultState
            flagsStorage[index].isOverride = flagsStorage[index].isLocal
        }
    }
    
}
