import Foundation

// MARK: - FeatureTogglesStorageType

public enum FeatureTogglesStorageType {
    case inMemory(appFlags: [any FeatureFlagsEnum])
    case userDefaults(appFlags: [any FeatureFlagsEnum])
    case custom(FeatureTogglesStorage)
    
    public var storage: FeatureTogglesStorage {
        switch self {
        case .inMemory(let appFlags):
            return InMemoryStorage(appFlags: appFlags)
        case .userDefaults(let appFlags):
            return UserDefaultsStorage(appFlags: appFlags)
        case .custom(let storage):
            return storage
        }
    }
}

// MARK: - FeatureTogglesStorage

public protocol FeatureTogglesStorage {
    
    /// Save all flags to storage
    func save(flags: [SDKFeatureFlag])
    
    /// If storage have local feature flags then remoteFlags will compare with storage flags and change their remote state
    /// else all remoteFlags will be stored
    func save(remoteFlags: [SDKFeatureFlag])
    
    func save(hash: String)
    func getHash() -> String?
    func getByName(name: String) -> SDKFeatureFlag?
    func getFlags() -> [SDKFeatureFlag]
    func clear()
    
    func changeLocalState(name: String, value: Bool)
    func changeOverrideState(name: String, value: Bool)
    
    func resetToDefaultValues()
    
}
