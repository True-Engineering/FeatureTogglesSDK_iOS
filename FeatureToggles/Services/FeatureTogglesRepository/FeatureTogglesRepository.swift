import Foundation

protocol FeatureTogglesRepository {
    
    // MARK: - Properties
    
    var didUpdate: (() -> Void)? { get set }
    
    // MARK: - Methods
    
    func checkHash(hash: String?)
    
    func getByName(name: String) -> SDKFeatureFlag?
    func getFlags() -> [SDKFeatureFlag]
    
    func loadFeaturesFromRemote()
    
    func changeLocalState(name: String, value: Bool)
    func changeOverrideState(name: String, value: Bool)
    
    func resetToDefaultValues()
    
}
