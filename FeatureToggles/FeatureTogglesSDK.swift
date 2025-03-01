import Foundation

public protocol FeatureTogglesSDKDelegate: AnyObject {
    
    /// Method will call when storage will update successfully
    func didFeatureTogglesStorageUpdateSuccessfully()
    
    /// Method will call when storage will update failed
    func didFeatureTogglesStorageUpdateFailed(httpErrorCode: Int?)
    
}

public class FeatureTogglesSDK {
    
    // MARK: - Properties
    
    private var repository: FeatureTogglesRepository
    private var headerKey: String
    private var featuresLink: String
    
    /// Intercept callback after request. You can use it for logging
    public var interceptRequest: ((RequestDataModel) -> Void)?
    /// Intercept callback after response. You can use it for logging
    public var interceptResponse: ((RequestDataModel) -> Void)?
    
    // MARK: - Delegates
    
    public weak var delegate: FeatureTogglesSDKDelegate?
    
    /// Delegates for ssl pinning and file loading
    public static var urlSessionDelegates = InterceptorURLSessionDelegatesArray()
    
    // MARK: - Constants
    
    public enum Constants {
        public static let defaultHeaderKey = "ff-hash"
        public static let defaultAPIFeaturesPath = "/api/features"
    }
    
    // MARK: - Init
    
    /// Init SDK
    ///
    /// - Parameters:
    ///   - storageType: Type of feature toggles storage.
    ///                 There are `inMemory`, `userDefaults` and `custom` storages.
    ///                 Default value is `userDefaults(appFlags: [])`.
    ///                 - appFlags: your custom enum flags with FeatureFlagsEnum type. Use this parameter for local defenition of FF list.
    ///                           if it is empty then SDK use all FF from server for storing
    ///   - headerKey: The header for hash in responses.
    ///                Default value is `ff-hash`.
    ///   - baseUrl: URL of host.
    ///   - apiFeaturePath: Path to method.
    ///                     Default value is `/api/features`
    ///   - featuresHeaders: Additional headers for feature toggles request.
    ///                      If you don't use sdk interceptor for requests, you can add headers here.
    ///                      Default value is `[:]`
    ///   - certificates: Certificates for ssl-pinning.
    ///                   Default value is `nil`
    ///   - publicKeyHash: Public key hash for ssl-pinning.
    ///                    Default value is `nil`
    public init(storageType: FeatureTogglesStorageType = .userDefaults(appFlags: []),
                headerKey: String = Constants.defaultHeaderKey,
                baseUrl: String,
                apiFeaturesPath: String = Constants.defaultAPIFeaturesPath,
                featuresHeaders: [String: String] = [:],
                certificates: [Data]? = nil,
                publicKeyHash: String? = nil) {
        if headerKey.isEmpty {
            print("FF header key have to be not empty!")
        }
        self.headerKey = headerKey
        
        if baseUrl.isEmpty {
            print("FF base url have to be not empty!")
        }
        featuresLink = "\(baseUrl)\(apiFeaturesPath)"
        
        InterceptorService.shared.certificates = certificates
        InterceptorService.shared.publicKeyHash = publicKeyHash
        InterceptorService.shared.host = URL(string: baseUrl)?.host ?? ""
        
        let service = FeatureFlagServiceImpl(endpoint: featuresLink, headers: featuresHeaders)
        self.repository = FeatureTogglesRepositoryImpl(storage: storageType.storage, service: service)
        self.repository.didUpdateSuccess = { [weak self] in
            self?.delegate?.didFeatureTogglesStorageUpdateSuccessfully()
        }
        
        self.repository.didUpdateFail = { [weak self] httpErrorCode in
            self?.delegate?.didFeatureTogglesStorageUpdateFailed(httpErrorCode: httpErrorCode)
        }
        
        InterceptorService.shared.modifiedList().forEach { _ in
            InterceptorService.shared.removeModifier(at: 0)
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
    public func getFlags() -> [SDKFeatureFlag] {
        return repository.getFlags()
    }
    
    /// Check hash in response headers and update storage if hash was changed.
    /// Use it if sdk interceptor doesn't fit to your project.
    public func obtainHash(headers: [String: String]) {
        guard let hash = headers[headerKey] else { return }
        repository.checkHash(hash: hash)
    }
    
    /// Get flags from server and save to storage
    public func loadRemote() {
        repository.loadFeaturesFromRemote()
    }
    
    /// Change local state in storage
    public func changeLocalState(name: String, value: Bool) {
        repository.changeLocalState(name: name, value: value)
    }
    
    /// Change `useLocal` state in storage. If `useLocal` state is true then `isEnabled` will get local state
    public func changeUseLocalState(name: String, value: Bool) {
        repository.changeUseLocalState(name: name, value: value)
    }
    
    /// Reset local values to default values (your appFlag value or server value).
    /// Reset `useLocal` to false for server flags
    public func resetToDefaultValues() {
        repository.resetToDefaultValues()
    }
    
    public func clearStorage() {
        repository.clear()
    }
    
}

// MARK: - Interceptor methods

extension FeatureTogglesSDK {
    
    /// Start automatic feature toggles updation
    public func startInterceptor() {
        InterceptorService.shared.startInterceptor()
        InterceptorService.shared.startListener()
        RequestBroadcast.shared.setDelegate(self)
    }
    
    /// Stop automatic feature toggles updation
    public func stopInterceptor() {
        InterceptorService.shared.stopInterceptor()
        InterceptorService.shared.stopListener()
    }
    
    /// If you start interceptor, you can add header for all requests, which will intercept
    /// You can use it for token, for example
    public func addInterceptorHeader(header: String, value: String) {
        let header = HeaderModifyModel(key: header, value: value)
        let headerModifier = RequestEvaluatorModifierHeader(header: header)
        InterceptorService.shared.modify(modifier: headerModifier)
    }
    
    /// If you start interceptor, you can add headers for all requests, which will intercept
    /// You can use it for token, for example
    public func addInterceptorHeaders(headers: [String: String]) {
        headers.forEach {
            addInterceptorHeader(header: $0.key, value: $0.value)
        }
    }
    
}

// MARK: - RequestBroadcastDelegate

extension FeatureTogglesSDK: RequestBroadcastDelegate {
    
    public func newRequestArrived(_ request: RequestDataModel) {
        guard let responseHeaders = request.responseHeaders else {
            interceptRequest?(request)
            return
        }
        interceptResponse?(request)
        guard request.url != featuresLink else { return }
        obtainHash(headers: responseHeaders)
    }
    
}
