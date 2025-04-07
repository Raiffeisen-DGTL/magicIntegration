//
//  Module.swift
//  RaifMagic
//
//  Created by USOV Vasily on 11.02.2025.
//

import Foundation
import SwiftUI

/// Project module interface
///
/// All supported projects ultimately return objects covered by this protocol.
/// This ensures unified work with various projects in Magic
public protocol IProjectModule: Sendable, Equatable, Identifiable where ID == Int {
    var id: Int { get }
    var name: String { get }
}

public extension IProjectModule {
    
    var id: Int {
        name.hashValue
    }
    
    /// The function is used to compare module models
    ///
    /// The reason for using it is that SwiftUI.Table and SwitfUI.onChange require passing Equatable values,
    /// and since modules can be of different types, it is not possible to compare them directly
    func compare(with: any IProjectModule) -> Bool {
        guard let comparedModule = with as? Self else {
            return false
        }
        return self == comparedModule
    }
}
