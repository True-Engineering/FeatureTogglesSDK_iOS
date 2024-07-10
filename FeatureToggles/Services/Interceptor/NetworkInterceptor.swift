import Foundation

@objc class NetworkInterceptor: NSObject {
    
    // MARK: - Singleton
    
    @objc static let shared = NetworkInterceptor()
    
    // MARK: - Properties
    
    let networkRequestInterceptor = NetworkRequestInterceptor()
    
}

// MARK: - Public methods

extension NetworkInterceptor {

    func shouldRequestModify(urlRequest: URLRequest) -> Bool {
        for modifer in InterceptorService.shared.config.modifiers {
            if modifer.isActionAllowed(urlRequest: urlRequest) {
                return true
            }
        }
        return false
    }
    
}
