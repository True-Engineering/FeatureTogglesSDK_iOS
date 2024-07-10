import UIKit
import SwiftUI


public protocol TaskProgressDelegate: AnyObject {
    func task(_ url: URL, didRecieveProgress progress: Progress)
}

final class InterceptorService: NSObject {
    
    // MARK: - Singleton
    
    static let shared = InterceptorService()
    
    // MARK: - Delegates
    
    weak var urlSessionDelegate: InterceptorURLSessionDelegate?
    
    // MARK: - Properties
    
    internal var interceptorEnable = false
    internal var listenerEnable = false
    internal var swizzled = false
    
    let networkRequestInterceptor = NetworkRequestInterceptor()
    
    var ignore: Ignore = .disbaled
    
    lazy var config: NetworkInterceptorConfig = {
        var savedModifiers = [Modifier]().retrieveFromDisk()
        return NetworkInterceptorConfig(modifiers: savedModifiers)
    }()
    
}

// MARK: - Private methods

extension InterceptorService {
    
    private func checkSwizzling() {
        if swizzled == false {
            self.networkRequestInterceptor.swizzleProtocolClasses()
            swizzled = true
        }
    }
    
}

// MARK: - Public methods

extension InterceptorService {
    
    func startInterceptor() {
        self.networkRequestInterceptor.startInterceptor()
        checkSwizzling()
    }

    func stopInterceptor() {
        self.networkRequestInterceptor.stopInterceptor()
        checkSwizzling()
    }

    func startListener() {
        self.networkRequestInterceptor.startListener()
        checkSwizzling()
    }

    func stopListener() {
        self.networkRequestInterceptor.stopListener()
        checkSwizzling()
    }
    
    func modify(modifier: Modifier) {
        config.addModifier(modifier: modifier)
    }
    
    func modifiedList() -> [Modifier] {
        return config.modifiers
    }
    
    func removeModifier(at index: Int) {
        return config.removeModifier(at: index)
    }

}
