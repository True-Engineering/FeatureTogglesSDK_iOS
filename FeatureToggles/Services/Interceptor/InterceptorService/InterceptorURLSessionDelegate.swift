//
//  InterceptorURLSessionDelegate.swift
//  FeatureToggles
//
//  Created by Anastasia on 11.07.2024.
//

import Foundation

public protocol InterceptorURLSessionDelegate: AnyObject {
    
    func interceptorURLSession(_ session: URLSession, 
                               task: URLSessionTask,
                               didSendBodyData bytesSent: Int64,
                               totalBytesSent: Int64,
                               totalBytesExpectedToSend: Int64)
    
}

extension InterceptorURLSessionDelegate {
    
    func interceptorURLSession(_ session: URLSession,
                               task: URLSessionTask,
                               didSendBodyData bytesSent: Int64,
                               totalBytesSent: Int64,
                               totalBytesExpectedToSend: Int64) {}
    
}
