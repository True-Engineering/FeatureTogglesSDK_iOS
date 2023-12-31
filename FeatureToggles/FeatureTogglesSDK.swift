import Foundation
import NetShears

public protocol FeatureTogglesSDKDelegate: AnyObject {
    
    /// Method will call when storage will update
    func didFeatureTogglesStorageUpdate()
    
}

public class FeatureTogglesSDK {
    
    private var repository: FeatureTogglesRepository
    private var headerKey: String
    private var featuresLink: String
    
    public var delegate: FeatureTogglesSDKDelegate?
    
    /// Intercept callback after request. You can use it for logging
    public var interceptRequest: ((NetShearsRequestModel) -> Void)?
    /// Intercept callback after response. You can use it for logging
    public var interceptResponse: ((NetShearsRequestModel) -> Void)?
    
    public enum Constants {
        public static let defaultHeaderKey = "FF-Hash"
        public static let defaultAPIFeaturesPath = "/api/features"
    }
    
    /// Init SDK
    ///
    /// - Parameters:
    ///   - storageType: Type of feature toggles storage.
    ///                 There are `inMemory`, `userDefaults` and `custom` storages.
    ///                 Default value is `userDefaults`.
    ///   - headerKey: The header for hash in responses.
    ///                 Default value is `FF-Hash`.
    ///   - baseUrl: URL of host.
    ///   - apiFeaturePath: Path to method.
    ///                 Default value is `/api/features`
    ///   - featuresHeaders: Additional headers for feature toggles request.
    ///                 If you don't use sdk interceptor for requests, you can add headers here.
    ///                 Default value is `[:]`
    public init(storageType: FeatureTogglesStorageType = .userDefaults,
                headerKey: String = Constants.defaultHeaderKey,
                baseUrl: String,
                apiFeaturesPath: String = Constants.defaultAPIFeaturesPath,
                featuresHeaders: [String: String] = [:]) {
        if headerKey.isEmpty {
            print("FF header key have to be not empty!")
        }
        self.headerKey = headerKey
        
        if baseUrl.isEmpty {
            print("FF base url have to be not empty!")
        }
        featuresLink = "\(baseUrl)\(apiFeaturesPath)"
        
        let service = FeatureFlagServiceImpl(endpoint: featuresLink, headers: featuresHeaders)
        self.repository = FeatureTogglesRepositoryImpl(storage: storageType.storage, service: service)
        self.repository.didUpdate = { [weak self] in
            self?.delegate?.didFeatureTogglesStorageUpdate()
        }
        
        NetShears.shared.modifiedList().forEach { _ in
            NetShears.shared.removeModifier(at: 0)
        }
    }
    
    deinit {
        stopInterceptor()
    }
    
}

// MARK: - Feature toggles methods

extension FeatureTogglesSDK {
    
    /// Check flag enabled status.
    public func isEnabled(flag: String) -> Bool {
        return repository.getByName(name: flag)?.isEnabled == true
    }
    
    /// Check flags enabled status. If disabled flag exists then false
    public func isEnabled(flags: [String]) -> Bool {
        return flags.first { !isEnabled(flag: $0) } == nil
    }
    
    /// Get flags from storage
    public func getFlags() -> [SDKFlag] {
        return repository.getFlags()
    }
    
    /// Check hash in response headers and update storage if hash was changed.
    /// Use it if sdk interceptor doesn't fit to your project.
    public func obtainHash(headers: [String: String]) {
        let hash = headers[headerKey]
        repository.checkHash(hash: hash)
    }
    
    /// Get flags from server and save to storage
    public func loadRemote() {
        repository.loadFeaturesFromRemote()
    }
    
}

// MARK: - Interceptor methods
    
extension FeatureTogglesSDK {
    
    /// Start automatic feature toggles updation
    public func startInterceptor() {
        NetShears.shared.startInterceptor()
        NetShears.shared.startListener()
        RequestBroadcast.shared.setDelegate(self)
    }
    
    /// Stop automatic feature toggles updation
    public func stopInterceptor() {
        NetShears.shared.stopInterceptor()
        NetShears.shared.stopListener()
    }
    
    /// If you start interceptor, you can add header for all requests, which will intercept
    /// You can use it for token, for example
    public func addInterceptorHeader(header: String, value: String) {
        let header = HeaderModifyModel(key: header, value: value)
        let headerModifier = RequestEvaluatorModifierHeader(header: header)
        NetShears.shared.modify(modifier: headerModifier)
    }
    
    /// If you start interceptor, you can add headers for all requests, which will intercept
    /// You can use it for token, for example
    public func addInterceptorHeaders(headers: [String: String]) {
        headers.forEach {
            addInterceptorHeader(header: $0.key, value: $0.value)
        }
    }
    
}

extension FeatureTogglesSDK: RequestBroadcastDelegate {

    public func newRequestArrived(_ request: NetShearsRequestModel) {
        guard let responseHeaders = request.responseHeaders else {
            interceptRequest?(request)
            return
        }
        interceptResponse?(request)
        guard request.url != featuresLink else { return }
        obtainHash(headers: responseHeaders)
    }

}
