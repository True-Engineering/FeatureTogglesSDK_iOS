import Foundation

internal class FeatureFlagServiceImpl {
    
    // MARK: - Properties
    
    private var endpoint: String
    private var headers: [String: String] = [:]
    
    // MARK: - Init
    
    init(endpoint: String, headers: [String: String]) {
        self.endpoint = endpoint
        self.headers = headers
    }
    
}

// MARK: - FeatureFlagService
    
extension FeatureFlagServiceImpl: FeatureFlagService {
    
    func loadFeatureToggles(completion: @escaping ((SDKFlagsWithHash) -> Void)) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            guard let data,
                  let featureFlagsWithHash = try? JSONDecoder().decode(FeatureFlagsWithHash.self,
                                                               from: data) else { return }
            
            let featureFlags = featureFlagsWithHash.featureFlags.map { SDKFlag(name: $0.key,
                                                                               isEnabled: $0.value.enable,
                                                                               description: $0.value.description,
                                                                               group: $0.value.group) }
            let hash = featureFlagsWithHash.featureFlagsHash
            
            completion(SDKFlagsWithHash(flags: featureFlags, hash: hash))
        }
        
        task.resume()
    }
}
