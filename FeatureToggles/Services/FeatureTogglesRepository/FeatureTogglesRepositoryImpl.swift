import Foundation

class FeatureTogglesRepositoryImpl: FeatureTogglesRepository {
    
    // MARK: - Properties
    
    private var storage: FeatureTogglesStorage
    private var service: FeatureFlagService
    private var lock = NSLock()
    
    var didUpdateSuccess: (() -> Void)?
    var didUpdateFail: ((Int?) -> Void)?
    
    // MARK: - Init
    
    init(storage: FeatureTogglesStorage, service: FeatureFlagService) {
        self.storage = storage
        self.service = service
    }
    
}

// MARK: - FeatureTogglesRepository methods

extension FeatureTogglesRepositoryImpl {
    
    func checkHash(hash: String) {
        lock.lock()
        if storage.getHash() != hash {
            loadFeaturesFromRemote()
        }
        lock.unlock()
    }
    
    func getByName(name: String) -> SDKFeatureFlag? {
        lock.lock()
        let flag = storage.getByName(name: name)
        lock.unlock()
        return flag
    }
    
    func getFlags() -> [SDKFeatureFlag] {
        lock.lock()
        let flags = storage.getFlags()
        lock.unlock()
        return flags
    }
    
    func loadFeaturesFromRemote() {
        service.loadFeatureToggles { [weak self] featureToggles, httpErrorCode in
            guard let self, let featureToggles else {
                DispatchQueue.main.async {
                    self?.didUpdateFail?(httpErrorCode)
                }
                return
            }
            self.lock.lock()
            self.storage.save(hash: featureToggles.hash)
            self.storage.save(remoteFlags: featureToggles.flags)
            self.lock.unlock()
            DispatchQueue.main.async {
                self.didUpdateSuccess?()
            }
        }
    }
    
    func changeUseLocalState(name: String, value: Bool) {
        lock.lock()
        storage.changeUseLocalState(name: name, value: value)
        lock.unlock()
    }
    
    func changeLocalState(name: String, value: Bool) {
        lock.lock()
        storage.changeLocalState(name: name, value: value)
        lock.unlock()
    }
    
    func resetToDefaultValues() {
        lock.lock()
        storage.resetToDefaultValues()
        lock.unlock()
        didUpdateSuccess?()
    }
    
    func clear() {
        self.storage.clear()
    }
    
}
