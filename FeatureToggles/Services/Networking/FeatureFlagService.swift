import Foundation

protocol FeatureFlagService {
    
    func loadFeatureToggles(completion: @escaping ((SDKFlagsWithHash) -> Void))
    
}
