import Foundation

protocol FeatureTogglesRepository {
    
    // MARK: - Properties
    
    var didUpdate: (() -> Void)? { get set }
    
    // MARK: - Methods
    
    func checkHash(hash: String?)
    
    func getByName(name: String) -> SDKFlag?
    func getFlags() -> [SDKFlag]
    
    func loadFeaturesFromRemote()
    
}
