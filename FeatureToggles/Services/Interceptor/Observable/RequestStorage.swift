import Foundation

final class RequestStorage: RequestObserverProtocol {
    
    // MARK: - Singleton
    
    static let shared = RequestStorage()
    
    // MARK: - Properties
    
    private let accessQueue = DispatchQueue(label: "interceptor.queue", attributes: .concurrent)
    
    private(set) var requests: [RequestDataModel] = []
    
    var filteredRequests: [RequestDataModel] {
        getFilteredRequests()
    }
    
    // MARK: - Init

    private init() {}
    
}

// MARK: - Public methods

extension RequestStorage {
    
    func newRequestArrived(_ request: RequestDataModel) {
        saveRequest(request: request)
    }
    
}
    
// MARK: - Private methods
    
extension RequestStorage {
    
    private func saveRequest(request: RequestDataModel) {
        accessQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            
            if let index = self.requests.firstIndex(where: { (req) -> Bool in
                return request.id == req.id ? true : false
            }) {
                self.requests[index] = request
            } else {
                self.requests.insert(request, at: 0)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.NewRequestNotification, object: nil)
        }
    }
    
    private func clearRequests() {
        accessQueue.async(flags: .barrier) { [weak self] in
            self?.requests.removeAll()
        }
    }
    
    private func getFilteredRequests() -> [RequestDataModel] {
        var localRequests = [RequestDataModel]()
        
        accessQueue.sync {
            localRequests = requests
        }
        
        return Self.filterRequestsIfNeeded(localRequests)
    }

    private static func filterRequestsIfNeeded(_ requests: [RequestDataModel]) -> [RequestDataModel] {
        guard case Ignore.enabled(let ignoreHandler) = InterceptorService.shared.ignore else {
            return requests
        }
        
        return  requests.filter { ignoreHandler($0) == false }
    }

}
