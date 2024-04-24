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
    
}

struct SDKFlagsWithHash {
    
    // MARK: - Properties
    
    var flags: [SDKFlag]
    var hash: String
    
}
