import Foundation
import SwiftUI

public struct SDKFlag: Codable, Identifiable {
    
    // MARK: - Properties
    
    public var name: String
    public var isEnabled: Bool
    public var description: String?
    public var group: String?
    
    public var id: String {
        return name
    }
    
    // MARK: - Init
    
    public init(name: String,
                isEnabled: Bool,
                description: String? = nil,
                group: String? = nil) {
        self.name = name
        self.isEnabled = isEnabled
        self.description = description
        self.group = group
    }
    
}

struct SDKFlagsWithHash {
    
    // MARK: - Properties
    
    var flags: [SDKFlag]
    var hash: String
    
}
