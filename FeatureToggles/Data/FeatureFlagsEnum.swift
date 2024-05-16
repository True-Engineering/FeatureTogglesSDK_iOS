//
//  FeatureFlagsEnum.swift
//
//
//  Created by Anastasia on 15.05.2024.
//

import Foundation

public protocol FeatureFlagsEnum: CaseIterable {
    
    // MARK: - Properties
    
    var uid: String { get }
    var description: String? { get }
    var defaultState: Bool { get }
    var group: String? { get }
    
}
