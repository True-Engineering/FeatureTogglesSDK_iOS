import Foundation

protocol FeatureFlagService {
    
    func loadFeatureToggles(completion: @escaping ((SDKFeatureFlagsWithHash?) -> Void))
    
}
