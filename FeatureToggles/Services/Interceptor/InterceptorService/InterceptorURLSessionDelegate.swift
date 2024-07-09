//
//  InterceptorURLSessionDelegate.swift
//  FeatureToggles
//
//  Created by Anastasia on 11.07.2024.
//

import Foundation

public protocol InterceptorURLSessionDelegate: AnyObject {
    
    func interceptorURLSession(_ session: URLSession, 
                               didReceive challenge: URLAuthenticationChallenge,
                               completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    
    func interceptorURLSession(_ session: URLSession, 
                               task: URLSessionTask,
                               didSendBodyData bytesSent: Int64,
                               totalBytesSent: Int64,
                               totalBytesExpectedToSend: Int64)
    
}

extension InterceptorURLSessionDelegate {
    
    func interceptorURLSession(_ session: URLSession, 
                               didReceive challenge: URLAuthenticationChallenge,
                               completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        InterceptorService.shared.checkSessionChallenge(session: session, challenge: challenge, completionHandler: completionHandler)
    }
    
    func interceptorURLSession(_ session: URLSession,
                               task: URLSessionTask,
                               didSendBodyData bytesSent: Int64,
                               totalBytesSent: Int64,
                               totalBytesExpectedToSend: Int64) {}
    
}
