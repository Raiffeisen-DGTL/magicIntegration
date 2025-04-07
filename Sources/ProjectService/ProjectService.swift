//
//  ProjectService.swift
//  RaifMagic
//
//  Created by USOV Vasily on 11.02.2025.
//

import SwiftUI
import CommandExecutor

/// Service for working with the project
public protocol IProjectService: Sendable {
    associatedtype Configuration: IProjectConfiguration
    
    var projectID: String { get }
    var projectURL: URL { get }
    var minimalSupportedRaifMagicVersion: AppVersionIdentifier { get }
    
    init(di: ProjectIntegrationDIContainer, projectURL: URL, configuration: Configuration)
    func fetchProjectModules() throws -> [any IProjectModule]
    func generationScenario() -> CommandScenario
    
    @MainActor
    func onInitialLoading(console: IConsole) async -> Void
    
    var isCurrentUserAdmin: Bool { get }
}

