//
//  Project.swift
//  RaifMagic
//
//  Created by USOV Vasily on 13.02.2025.
//

@_exported import RaifMagicCore
import CommandExecutor
import Foundation

/// Project description for its integration into RaifMagic
public protocol IProject {
    associatedtype Configuration: IProjectConfiguration
    associatedtype Service: IProjectService where Service.Configuration == Configuration
    
    /// Description of project
    var description: String { get }
    var di: ProjectIntegrationDIContainer { get }
    /// Unique identificator of project.
    ///
    /// Current ID must be equal with `project_id` in `.magic.json` file in projects root folder
    var projectID: String { get }
    /// URL of project
    var url: URL { get }
    
    init(url: URL, di: ProjectIntegrationDIContainer)
    
    func loadConfiguration() -> Configuration?
    func makeService() -> Service?
}

public extension IProject {
    
    func loadConfiguration() -> Configuration? {
        let configurationFileURL = url.appending(path: ".magic.json")
        return Configuration.init(configurationFileURL: configurationFileURL)
    }
    
    func makeService() -> Service? {
        guard let configuration = loadConfiguration() else { return nil }
        return Service.init(di: di, projectURL: url, configuration: configuration)
    }
    
}

// MARK: - DI

/// Container, that pass into project service
public final class ProjectIntegrationDIContainer: Sendable {
    public let logger: Logger
    public let executor: CommandExecutor
    
    public init(logger: Logger, executor: CommandExecutor) {
        self.logger = logger
        self.executor = executor
    }
}
