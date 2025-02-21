import Foundation

protocol FeatureTogglesRepository {
    
    // MARK: - Properties
    
    var didUpdateSuccess: (() -> Void)? { get set }
    var didUpdateFail: ((Int?) -> Void)? { get set }
    
    // MARK: - Methods
    
    func checkHash(hash: String)
    
    func getByName(name: String) -> SDKFeatureFlag?
    func getFlags() -> [SDKFeatureFlag]
    
    func loadFeaturesFromRemote()
    
    func changeLocalState(name: String, value: Bool)
    func changeUseLocalState(name: String, value: Bool)
    
    func resetToDefaultValues()
    func clear()
    
}
