import Foundation

public struct RequestEvaluatorModifierEndpoint: RequestEvaluatorModifier, Equatable {
    
    // MARK: - Properties
    
    public var redirectedRequest: RedirectedRequestModel
    
    public static let storeFileName = "Modifier.txt"
    
    // MARK: - Init
    
    public init(redirectedRequest: RedirectedRequestModel) {
        self.redirectedRequest = redirectedRequest
    }
    
}

// MARK: - Public methods

extension RequestEvaluatorModifierEndpoint {
    
    public func modify(request: inout URLRequest) {
        if isRequestRedirectable(urlRequest: request) {
            request.modifyURLRequestEndpoint(redirectUrl: redirectedRequest)
        }
    }
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        return isRequestRedirectable(urlRequest: urlRequest)
    }
    
    func isRequestRedirectable(urlRequest: URLRequest) -> Bool {
        guard let urlString = urlRequest.url?.absoluteString else {
            return false
        }
        
        if urlString.contains(redirectedRequest.originalUrl) {
            return true
        }
        
        return false
    }
    
}
