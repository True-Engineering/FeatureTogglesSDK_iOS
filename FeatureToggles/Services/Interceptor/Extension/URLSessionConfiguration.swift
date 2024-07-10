import Foundation

extension URLSessionConfiguration {
    
    @objc func fakeProcotolClasses() -> [AnyClass]? {
        guard let fakeProcotolClasses = self.fakeProcotolClasses() else {
            return []
        }
        
        var originalProtocolClasses = fakeProcotolClasses.filter {
            return $0 != NetworkInterceptorUrlProtocol.self && $0 != NetworkListenerUrlProtocol.self
        }
        
        if InterceptorService.shared.listenerEnable {
            originalProtocolClasses.insert(NetworkListenerUrlProtocol.self, at: 0)
        }
        
        if InterceptorService.shared.interceptorEnable {
            originalProtocolClasses.insert(NetworkInterceptorUrlProtocol.self, at: 0)
        }
        
        return originalProtocolClasses
    }
    
}
