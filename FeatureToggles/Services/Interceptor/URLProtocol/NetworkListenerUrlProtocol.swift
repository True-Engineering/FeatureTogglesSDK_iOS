import Foundation

private enum Constants {
    static let requestHandledKey = "NetworkListenerUrlProtocol"
}

class NetworkListenerUrlProtocol: URLProtocol {
    
    // MARK: - Properties
    
    var session: URLSession?
    var sessionTask: URLSessionDataTask?
    var currentRequest: RequestDataModel?
    
    lazy var requestObserver: RequestObserverProtocol = RequestObserver(options: [RequestBroadcast.shared])
    
    // MARK: - Init
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        session = nil
        sessionTask = nil
        currentRequest = nil
    }
    
    // MARK: - URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        
        if NetworkListenerUrlProtocol.property(forKey: Constants.requestHandledKey, in: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
        NetworkListenerUrlProtocol.setProperty(true, forKey: Constants.requestHandledKey, in: newRequest)
        sessionTask = session?.dataTask(with: newRequest as URLRequest)
        sessionTask?.resume()
        
        currentRequest = RequestDataModel(request: newRequest, session: session)
        if let request = currentRequest {
            requestObserver.newRequestArrived(request)
        }
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
        currentRequest?.httpBody = body(from: request)
        if let startDate = currentRequest?.date {
            currentRequest?.duration = fabs(startDate.timeIntervalSinceNow) * 1000 // Find elapsed time and convert to milliseconds
        }
        currentRequest?.isFinished = true
        
        if let request = currentRequest {
            requestObserver.newRequestArrived(request)
        }
        session?.invalidateAndCancel()
    }
    
}

// MARK: - Private methods

extension NetworkListenerUrlProtocol {
    
    private func body(from request: URLRequest) -> Data? {
        /// The receiver will have either an HTTP body or an HTTP body stream only one may be set for a request.
        /// A HTTP body stream is preserved when copying an NSURLRequest object,
        /// but is lost when a request is archived using the NSCoding protocol.
        return request.httpBody ?? request.getHttpBodyStreamData()
    }
    
}

// MARK: - URLSessionDataDelegate

extension NetworkListenerUrlProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        if currentRequest?.dataResponse == nil {
            currentRequest?.dataResponse = data
        } else {
            currentRequest?.dataResponse?.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, 
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        currentRequest?.initResponse(response: response)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            currentRequest?.errorClientDescription = error.localizedDescription
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(_ session: URLSession, 
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error else { return }
        currentRequest?.errorClientDescription = error.localizedDescription
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(_ session: URLSession, 
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let delegate = FeatureTogglesSDK.urlSessionDelegates.delegates.first else {
            InterceptorService.shared.checkSessionChallenge(session: session, challenge: challenge, completionHandler: completionHandler)
            return
        }
        
        delegate.interceptorURLSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(_ session: URLSession, 
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        FeatureTogglesSDK.urlSessionDelegates.delegates.forEach {
            $0.interceptorURLSession(session,
                                     task: task,
                                     didSendBodyData: bytesSent,
                                     totalBytesSent: totalBytesSent,
                                     totalBytesExpectedToSend: totalBytesExpectedToSend)
        }
    }
    
}
