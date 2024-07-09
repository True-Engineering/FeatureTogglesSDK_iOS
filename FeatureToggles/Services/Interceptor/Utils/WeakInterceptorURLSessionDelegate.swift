import Foundation

internal class WeakInterceptorURLSessionDelegate {
    
    // MARK: - Properties
    
    private var identifier = UUID()
    
    internal private(set) weak var object: InterceptorURLSessionDelegate?
    
    // MARK: - Init
    
    internal init(object: InterceptorURLSessionDelegate) {
        self.object = object
    }
}

// MARK: - Equatable

extension WeakInterceptorURLSessionDelegate: Equatable {
    
    public static func == (lhs: WeakInterceptorURLSessionDelegate, rhs: WeakInterceptorURLSessionDelegate) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
}
