//
//  ProjectConfiguration.swift
//  RaifMagic
//
//  Created by USOV Vasily on 11.02.2025.
//

import Foundation

/// Service for loading configurations of registered projects
///
/// The service attempts to load configurations for all registered project types from the specified path.
public final class ProjectsLoader: Sendable {
    private let di: ProjectIntegrationDIContainer
    private let supportedProjects: [any IProject.Type]
    public init(di: ProjectIntegrationDIContainer, supportedProjects: [any IProject.Type]) {
        self.di = di
        self.supportedProjects = supportedProjects
    }
    
    public func loadSupportedProjects(forURL url: URL) -> [any IProject] {
        supportedProjects.compactMap { project in
            let project = project.init(url: url, di: di)
            guard project.loadConfiguration() != nil else { return nil }
            return project
        }
    }
}

/// Project configuration
///
/// Configuration defines all basic elements of the project for its display in the list of projects and further opening
/// Configuration is responsible for creating a service for working with the project (method `makeProjectService`)
public protocol IProjectConfiguration: Sendable {
    var projectID: String { get }
    var minimalSupportedRaifMagicVersion: AppVersionIdentifier { get }
    
    init?(configurationFileURL: URL)
}
