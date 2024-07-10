import Foundation

public struct RequestEvaluatorModifierResponse: RequestEvaluatorActionModifier, Equatable {
    
    // MARK: - Properties
    
    public var response: HTTPResponseModifyModel
    
    public static let storeFileName = "Response.txt"
    
    // MARK: - Init
    
    public init(response: HTTPResponseModifyModel) {
        self.response = response
    }
    
}

// MARK: - Public methods

extension RequestEvaluatorModifierResponse {
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        URL(string: response.url) == urlRequest.url && urlRequest.httpMethod?.lowercased() == response.httpMethod.lowercased()
    }
    
    public func modify(client: URLProtocolClient?, urlProtocol: URLProtocol) {
        guard let urlResponse = response.response else { return }
        client?.urlProtocol(urlProtocol, didLoad: response.data)
        client?.urlProtocol(urlProtocol, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(urlProtocol)
    }
    
}
