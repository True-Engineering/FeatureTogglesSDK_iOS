import Foundation

public class InterceptorURLSessionDelegatesArray {
    
    // MARK: - Properties
    
    private var objects = ThreadSafe<[WeakInterceptorURLSessionDelegate]>([])
    
    // MARK: - Init
    
    public init() {}
    
}

// MARK: - Public functions

extension InterceptorURLSessionDelegatesArray {

    public func add(delegate: InterceptorURLSessionDelegate) {
        objects.atomically {
            if !$0.contains(where: { delegate === $0.object }) {
                $0.append(WeakInterceptorURLSessionDelegate(object: delegate))
            }
        }
    }

    public func remove(delegate: InterceptorURLSessionDelegate) {
        objects.atomically { array in
            array.removeAll { delegate === $0.object }
        }
    }

    public var delegates: [InterceptorURLSessionDelegate] {
        let result = objects.value.compactMap { $0.object }
        
        if result.count < objects.value.count {
            reap()
        }

        return result
    }
    
}

// MARK: - Private functions

extension InterceptorURLSessionDelegatesArray {

    private func reap() {
        objects.atomically { array in
            array.removeAll { $0.object == nil }
        }
    }
    
}

