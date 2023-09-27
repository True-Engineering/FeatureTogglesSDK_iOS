import Foundation

protocol FeatureTogglesRepository {
    
    var didUpdate: (() -> Void)? { get set }

    func checkHash(hash: String?)
    
    func getByName(name: String) -> SDKFlag?
    func getFlags() -> [SDKFlag]

    func loadFeaturesFromRemote()
    
}
