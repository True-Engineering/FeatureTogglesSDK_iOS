import Foundation

protocol RequestBroadcastDelegate: AnyObject {
    func newRequestArrived(_ request: RequestDataModel)
}

final class RequestBroadcast: RequestObserverProtocol {
    
    // MARK: - Singleton
    
    static let shared = RequestBroadcast()
    
    // MARK: - Delegates
    
    var delegate = ThreadSafe<RequestBroadcastDelegate?>(nil)
    
    // MARK: - Init
    
    private init() {}
    
}

// MARK: - Public methods

extension RequestBroadcast {

    func setDelegate(_ newDelegate: RequestBroadcastDelegate) {
        delegate.atomically { delegate in
            delegate = newDelegate
        }
    }

    func removeDelegate() {
        delegate.atomically { delegate in
            delegate = nil
        }
    }

    func newRequestArrived(_ request: RequestDataModel) {
        delegate.atomically { delegate in
            delegate?.newRequestArrived(request)
        }
    }
    
}
