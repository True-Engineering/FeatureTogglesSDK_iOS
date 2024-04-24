import Foundation

private enum Constants {
    static let sdkTitle = "[FeatureTogglesSDK] "
}

final class FeatureTogglesLoggingService {
    
    // MARK: - Singleton
    
    static let shared = FeatureTogglesLoggingService()
    
    // MARK: - Init
    
    private init() {}
    
}

extension FeatureTogglesLoggingService {
    
    func log(message: String) {
#if DEBUG
        print(Constants.sdkTitle + message)
#endif
    }
    
}
