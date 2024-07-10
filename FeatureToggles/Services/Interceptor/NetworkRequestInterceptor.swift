import Foundation

@objc class NetworkRequestInterceptor: NSObject{
    
    func swizzleProtocolClasses() {
        let instance = URLSessionConfiguration.default
        let uRLSessionConfigurationClass: AnyClass = object_getClass(instance)!
        
        let method1: Method = class_getInstanceMethod(uRLSessionConfigurationClass, #selector(getter: uRLSessionConfigurationClass.protocolClasses))!
        let method2: Method = class_getInstanceMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.fakeProcotolClasses))!
        
        method_exchangeImplementations(method1, method2)
    }

    func startInterceptor() {
        InterceptorService.shared.interceptorEnable = true
        URLProtocol.registerClass(NetworkInterceptorUrlProtocol.self)
    }

    func stopInterceptor() {
        InterceptorService.shared.interceptorEnable = false
        URLProtocol.unregisterClass(NetworkInterceptorUrlProtocol.self)
    }

    func startListener() {
        InterceptorService.shared.listenerEnable = true
        URLProtocol.registerClass(NetworkListenerUrlProtocol.self)
    }

    func stopListener() {
        InterceptorService.shared.listenerEnable = false
        URLProtocol.unregisterClass(NetworkListenerUrlProtocol.self)
    }
    
}


