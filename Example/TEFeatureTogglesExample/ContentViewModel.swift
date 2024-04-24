//
//  ContentViewModel.swift
//  TEFeatureTogglesExample
//
//  Created by Anastasia on 29.08.2023.
//

import Foundation
import FeatureToggles

final class ContentViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let featureTogglesSDK: FeatureTogglesSDK
    
    @Published private(set) var features: [SDKFlag] = []
    
    // MARK: - Init
    
    init() {
        featureTogglesSDK = FeatureTogglesSDK(storageType: .userDefaults,
                                              baseUrl: "http://localhost:8080",
                                              featuresHeaders: ["Test-Header-From-Init-For-Features": "Test"])
        featureTogglesSDK.startInterceptor()
        featureTogglesSDK.addInterceptorHeader(header: "Test-Header-From-Interceptor", value: "Test")
        featureTogglesSDK.delegate = self
        featureTogglesSDK.loadRemote()
        
        featureTogglesSDK.interceptRequest = { request in
            print("Intercept request: \(request.url)")
        }
        
        featureTogglesSDK.interceptResponse = { response in
            print("Intercept response: \(response.url)")
        }
    }
    
}

// MARK: - FeatureTogglesSDKDelegate

extension ContentViewModel: FeatureTogglesSDKDelegate {
    
    func didFeatureTogglesStorageUpdate() {
        features = featureTogglesSDK.getFlags()
    }
    
}
