import Foundation

class FeatureTogglesRepositoryImpl: FeatureTogglesRepository {
    
    // MARK: - Properties
    
    private var storage: FeatureTogglesStorage
    private var service: FeatureFlagService
    private var lock = NSLock()
    
    var didUpdate: (() -> Void)?
    
    // MARK: - Init
    
    init(storage: FeatureTogglesStorage, service: FeatureFlagService) {
        self.storage = storage
        self.service = service
    }
    
}

// MARK: - FeatureTogglesRepository methods

extension FeatureTogglesRepositoryImpl {
    
    func checkHash(hash: String?) {
        lock.lock()
        if storage.getHash() != hash {
            loadFeaturesFromRemote()
        }
        lock.unlock()
    }
    
    func getByName(name: String) -> SDKFlag? {
        lock.lock()
        let flag = storage.getByName(name: name)
        lock.unlock()
        return flag
    }
    
    func getFlags() -> [SDKFlag] {
        lock.lock()
        let flags = storage.getFlags()
        lock.unlock()
        return flags
    }
    
    func loadFeaturesFromRemote() {
        service.loadFeatureToggles { [weak self] featureToggles in
            guard let self else { return }
            self.lock.lock()
            self.storage.save(hash: featureToggles.hash)
            self.storage.clear()
            self.storage.save(flags: featureToggles.flags)
            self.lock.unlock()
            DispatchQueue.main.async {
                self.didUpdate?()
            }
        }
    }
}
