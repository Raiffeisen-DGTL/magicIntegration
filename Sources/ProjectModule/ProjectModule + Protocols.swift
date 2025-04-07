//
//  ProjectModule + Protocols.swift
//  RaifMagic
//
//  Created by USOV Vasily on 13.02.2025.
//

import Foundation

// Namespace for additional types - module characteristics
public enum ProjectModule {}

// MARK: - CodeOwners

public extension ProjectModule {
    protocol CodeOwnersSupported {
        var url: URL { get }
    }
}

// MARK: - Displayable

/// Model for which you can specify various additional information for output in the table and on the module page
public extension ProjectModule {
    protocol DisplayConfigurationSupported {
        var tableItemDescription: String? { get }
    }
}
