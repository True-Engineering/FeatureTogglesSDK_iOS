import Foundation

public enum FeatureTogglesStorageType {
    case inMemory
    case userDefaults
    case custom(FeatureTogglesStorage)
    
    public var storage: FeatureTogglesStorage {
        switch self {
        case .inMemory:
            return InMemoryStorage()
        case .userDefaults:
            return UserDefaultsPreferencesStorage()
        case .custom(let storage):
            return storage
        }
    }
}

public protocol FeatureTogglesStorage {
    
    func save(flags: [SDKFlag])
    func save(hash: String)
    func getHash() -> String?
    func getByName(name: String) -> SDKFlag?
    func getFlags() -> [SDKFlag]
    func clear()
    
}
