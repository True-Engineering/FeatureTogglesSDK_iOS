import Foundation

class InMemoryStorage: FeatureTogglesStorage {

    private var flagsStorage: [String: SDKFlag] = [:]
    private var flagsHash: String?

    func save(flags: [SDKFlag]) {
        flags.forEach {
            flagsStorage[$0.name] = $0
        }
    }

    func save(hash: String) {
        flagsHash = hash
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
    }
}
