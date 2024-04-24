import Foundation

struct FeatureFlagsWithHash: Codable {
    let featureFlags: [String: FeatureFlag]
    let featureFlagsHash: String
}

struct FeatureFlag: Codable {
    let uid: String
    let enable: Bool
    let description: String?
    let group: String?
    let permissions: [String]?
    let customProperties: [String: String]?
    let flippingStrategy: FeatureFlagStrategyDetails?
}

struct FeatureFlagStrategyDetails: Codable {
    let className: String?
    let initParams: [String: String]?
}
