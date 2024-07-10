import Foundation
import UIKit

public final class RequestDataModel: Codable {
    
    // MARK: - Properties
    
    public let id: String
    public let url: String
    public let host: String?
    public let port: Int?
    public let scheme: String?
    public let date: Date
    public let method: String
    public let headers: [String: String]
    public var credentials: [String : String]
    public var cookies: String?
    public var httpBody: Data?
    public var code: Int
    public var responseHeaders: [String: String]?
    public var dataResponse: Data?
    public var errorClientDescription: String?
    public var duration: Double?
    public var isFinished: Bool
    
    // MARK: - Init
    
    init(request: NSURLRequest, session: URLSession?) {
        id = UUID().uuidString
        url = request.url?.absoluteString ?? ""
        host = request.url?.host
        port = request.url?.port
        scheme = request.url?.scheme
        date = Date()
        method = request.httpMethod ?? "GET"
        credentials = [:]
        httpBody = request.httpBody
        code = 0
        isFinished = false
        
        // Collect all HTTP Request headers except the "Cookie" header. Many request representations treat cookies
        // with special parameters or structures. For cookie collection, refer to the bottom part of this method
        var headers = request.allHTTPHeaderFields ?? [:]
        session?.configuration.httpAdditionalHeaders?
            .filter {  $0.0 != AnyHashable("Cookie") }
            .forEach { element in
                guard let key = element.0 as? String, let value = element.1 as? String else { return }
                headers[key] = value
            }
        self.headers = headers
        
        // if the target server uses HTTP Basic Authentication, collect username and password
        if let credentialStorage = session?.configuration.urlCredentialStorage,
           let host = self.host,
           let port = self.port {
            let protectionSpace = URLProtectionSpace(host: host,
                                                     port: port,
                                                     protocol: scheme,
                                                     realm: host,
                                                     authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
            
            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password else { continue }
                    self.credentials[user] = password
                }
            }
        }
        
        //  collect cookies associated with the target host
        //  TODO: Add the else branch.
        /*  With the condition below, it is handled only the case where session.configuration.httpShouldSetCookies == true.
         Some developers could opt to handle cookie manually using the "Cookie" header stored in httpAdditionalHeaders
         and disabling the handling provided by URLSessionConfiguration (httpShouldSetCookies == false).
         See: https://developer.apple.com/documentation/foundation/nsurlsessionconfiguration/1411589-httpshouldsetcookies?language=objc
         */
        if let session, let url = request.url, session.configuration.httpShouldSetCookies {
            if let cookieStorage = session.configuration.httpCookieStorage,
               let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty {
                self.cookies = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
            }
        }
    }
    
    init(url: String,
         host: String,
         method: String,
         requestObject: Data?,
         responseObject: Data?,
         success: Bool,
         statusCode: Int,
         duration: Double?,
         scheme: String,
         requestHeaders: [String: String]?,
         responseHeaders: [String: String]?,
         isFinished: Bool = true) {
        self.id = UUID().uuidString
        self.method = method
        self.scheme = scheme
        self.url = url
        self.host = host
        self.httpBody = requestObject
        self.code = statusCode
        self.responseHeaders = responseHeaders
        self.headers = requestHeaders ?? [:]
        self.dataResponse = responseObject
        self.date = Date()
        self.port = nil
        self.duration = duration
        self.credentials = [:]
        self.isFinished = isFinished
    }
    
}

// MARK: - Public methods

extension RequestDataModel {
    
    func initResponse(response: URLResponse) {
        guard let responseHttp = response as? HTTPURLResponse else {return}
        code = responseHttp.statusCode
        responseHeaders = responseHttp.allHeaderFields as? [String: String]
    }
    
}
