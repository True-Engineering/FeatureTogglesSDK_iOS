//
//  AuthenticationChallengeSender.swift
//  FeatureToggles
//
//  Created by Anastasia on 15.07.2024.
//

import Foundation

class AuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    typealias AuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    // MARK: - Properties
    
    let handler: AuthenticationChallengeHandler
    
    // MARK: - Init
    
    init(handler: @escaping AuthenticationChallengeHandler) {
        self.handler = handler
        super.init()
    }
    
    // MARK: - Public methods
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }

    func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }

    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }

    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
