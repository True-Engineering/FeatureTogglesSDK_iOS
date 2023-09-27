import Foundation

public struct SDKFlag: Codable {
    public var name: String
    public var isEnabled: Bool
}

struct SDKFlagsWithHash {
    var flags: [SDKFlag]
    var hash: String
}
