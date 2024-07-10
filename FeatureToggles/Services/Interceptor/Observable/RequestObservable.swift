import Foundation

protocol RequestObserverProtocol {
    func newRequestArrived(_ request: RequestDataModel)
}

final class RequestObserver: RequestObserverProtocol {
    
    // MARK: - Properties
    
    let options: [RequestObserverProtocol]
    
    // MARK: - Init
    
    init(options: [RequestObserverProtocol]) {
        self.options = options
    }
    
}

// MARK: - Public methods

extension RequestObserver {
    
    func newRequestArrived(_ request: RequestDataModel) {
        options.forEach {
            $0.newRequestArrived(request)
        }
    }
    
}
