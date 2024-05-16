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
    
    func loadFeatureToggles(completion: @escaping ((SDKFeatureFlagsWithHash) -> Void)) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error  in
            guard let data else {
                if let error {
                    FeatureTogglesLoggingService.shared.log(message: "[Error] \(error.localizedDescription)")
                }
                return
            }
            
            guard let featureFlagsWithHash = try? JSONDecoder().decode(FeatureFlagsWithHash.self, from: data) else {
                FeatureTogglesLoggingService.shared.log(message: "[Error] Can't parse response to expected result.")
                return
            }
            
            let featureFlags = featureFlagsWithHash.featureFlags.map { SDKFeatureFlag(name: $0.key,
                                                                                      description: $0.value.description,
                                                                                      group: $0.value.group,
                                                                                      isEnabled: $0.value.enable) }
            let hash = featureFlagsWithHash.featureFlagsHash
            
            completion(SDKFeatureFlagsWithHash(flags: featureFlags, hash: hash))
        }
        
        task.resume()
    }
    
}
