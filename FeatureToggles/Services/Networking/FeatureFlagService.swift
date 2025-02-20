import Foundation

protocol FeatureFlagService {
    
    func loadFeatureToggles(completion: @escaping ((SDKFeatureFlagsWithHash?, Int?) -> Void))
    
}
