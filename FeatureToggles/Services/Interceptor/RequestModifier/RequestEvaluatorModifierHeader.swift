import Foundation

public struct RequestEvaluatorModifierHeader: RequestEvaluatorModifier, Equatable {
    
    // MARK: - Properties
    
    public var header: HeaderModifyModel
    
    public static let storeFileName = "Header.txt"
    
    // MARK: - Init
    
    public init(header: HeaderModifyModel) {
        self.header = header
    }
    
}

// MARK: - Public methods

extension RequestEvaluatorModifierHeader {
    
    public func modify(request: inout URLRequest) {
        request.modifyURLRequestHeader(header: header)
    }
    
    public func isActionAllowed(urlRequest: URLRequest) -> Bool {
        return true
    }
    
}
