import Foundation

public protocol FeatureFlagsEnum: CaseIterable {
    
    // MARK: - Properties
    
    var uid: String { get }
    var description: String? { get }
    var defaultState: Bool { get }
    var group: String? { get }
    
}
