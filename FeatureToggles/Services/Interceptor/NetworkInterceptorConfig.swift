import Foundation

public struct RedirectedRequestModel: Codable, Equatable {
    
    // MARK: - Properties
    
    public let originalUrl: String
    public let redirectUrl: String
    
    // MARK: - Init

    public init(originalUrl: String, redirectUrl: String) {
        self.originalUrl = originalUrl
        self.redirectUrl = redirectUrl
    }
}

public struct HeaderModifyModel: Codable, Equatable {
    
    // MARK: - Properties
    
    public let key: String
    public let value: String
    
    // MARK: - Init

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct HTTPResponseModifyModel: Codable, Equatable {
    
    // MARK: - Properties
    
    public let url: String
    public let httpMethod: String
    
    public let statusCode: Int
    public let data: Data
    public let httpVersion: String?
    public let headers: [String: String]
    
    public var response: URLResponse? {
        guard let url = URL(string: url) else { return nil }
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: httpVersion, headerFields: headers)
    }
    
    // MARK: - Init

    public init(url: String,
                data: Data,
                httpMethod: String = "GET",
                statusCode: Int = 200,
                httpVersion: String? = nil,
                headers: [String : String] = [:]) {
        self.url = url
        self.data = data
        self.httpMethod = httpMethod
        self.statusCode = statusCode
        self.httpVersion = httpVersion
        self.headers = headers
    }
}

final class NetworkInterceptorConfig {
    
    // MARK: - Properties
    
    var modifiers: [Modifier] = [] {
        didSet {
            modifiers.store()
        }
    }
    
    // MARK: - Init
    
    init(modifiers: [Modifier] = []) {
        self.modifiers = modifiers
    }
    
    // MARK: - Public methods
    
    func addModifier(modifier: Modifier) {
        self.modifiers.append(modifier)
    }
    
    func getModifiers() -> [Modifier] {
        return self.modifiers
    }
    
    func removeModifier(at index: Int) {
        guard index <= modifiers.count - 1 else { return }
        modifiers.remove(at: index)
    }

}


