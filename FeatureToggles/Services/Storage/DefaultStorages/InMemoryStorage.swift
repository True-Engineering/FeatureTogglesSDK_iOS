import Foundation

final class InMemoryStorage {
    
    // MARK: - Properties
    
    private var flagsStorage: [String: SDKFlag] = [:]
    private var flagsHash: String?
    
}

// MARK: - FeatureTogglesStorage

extension InMemoryStorage: FeatureTogglesStorage {
    
    func save(flags: [SDKFlag]) {
        flags.forEach {
            flagsStorage[$0.name] = $0
        }
        FeatureTogglesLoggingService.shared.log(message: "Feature flags were saved.")
    }
    
    func save(hash: String) {
        flagsHash = hash
        FeatureTogglesLoggingService.shared.log(message: "Hash was saved.")
    }
    
    func getHash() -> String? {
        return flagsHash
    }
    
    func getByName(name: String) -> SDKFlag? {
        return flagsStorage[name]
    }
    
    func getFlags() -> [SDKFlag] {
        return flagsStorage.map { $0.value }
    }
    
    func clear() {
        flagsHash = nil
        flagsStorage = [:]
        FeatureTogglesLoggingService.shared.log(message: "Feature flags storage was cleared.")
    }
    
}
