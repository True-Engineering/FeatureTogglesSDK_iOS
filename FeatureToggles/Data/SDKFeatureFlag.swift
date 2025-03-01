import Foundation
import SwiftUI

struct SDKFeatureFlagsWithHash {
    
    // MARK: - Properties
    
    var flags: [SDKFeatureFlag]
    var hash: String
    
}

public struct SDKFeatureFlag: Codable, Identifiable {
    
    // MARK: - Properties
    
    public var name: String
    public var description: String?
    public var group: String?
    
    public var remoteState: Bool?
    public var localState: Bool
    public var useLocal: Bool
    
    public var isEnabled: Bool {
        useLocal ? localState : remoteState ?? localState
    }
    
    public var isLocalFlag: Bool {
        remoteState == nil
    }
    
    public var id: String {
        return name
    }
    
    // MARK: - Init
    
    public init(name: String,
                description: String? = nil,
                group: String? = nil,
                remoteState: Bool? = nil,
                localState: Bool,
                useLocal: Bool = false) {
        self.name = name
        self.description = description
        self.group = group
        self.remoteState = remoteState
        self.localState = localState
        self.useLocal = useLocal
    }
    
    public init(name: String,
                description: String? = nil,
                group: String? = nil,
                isEnabled: Bool) {
        self.name = name
        self.description = description
        self.group = group
        self.remoteState = isEnabled
        self.localState = isEnabled
        self.useLocal = false
    }
    
}
