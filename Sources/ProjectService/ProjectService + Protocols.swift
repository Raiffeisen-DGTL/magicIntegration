//
//  ProjectService + Protocols.swift
//  RaifMagic
//
//  Created by USOV Vasily on 13.02.2025.
//

import SwiftUI
import CommandExecutor
import CodeOwners
import CodeStyler

// MARK: - Additional screens

public protocol CustomScreenSupported: IProjectService {
    @MainActor
    var mainMenuIntegrations: [MainMenuIntegration] { get }
}

// MARK: - Working with secrets (privacy data, passwords, tokens)

public protocol SecretsSupported: IProjectService {
    var secrets: [any SecretValue] { get }
    var secretsScreenSidebarActions: [CustomActionSection] { get }
    @MainActor
    func hidePrivacyContent(from source: String) async -> String
}

public protocol SecretValue: Identifiable {
    var id: Int { get }
    var title: String { get }
}

public protocol TextSecretValue: SecretValue {
    var title: String { get }
    @MainActor
    var currentValue: String { get async }
    @MainActor
    func onUpdate(_: String) async
}

// MARK: - Checking environment

/// Support for working with the environment
public protocol EnvironmentSupported: IProjectService {
    var environmentItems: [any EnvironmentItem] { get }
}

/// Environment element
public protocol EnvironmentItem: Identifiable, Sendable, Equatable {
    var id: Int { get }
    var title: String { get }
    var status: Status { get set }
    // TODO: Разобраться с @MainActor
    @MainActor
    func calculateStatus(_: CommandExecutor, _: Logger) async -> Status
}

public extension EnvironmentItem {
    var id: Int {
        title.hashValue
    }
}

public enum Status: Equatable, Sendable {
    public static func == (lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.actual, .actual): true
        case (.waiting, .waiting): true
        case (.inProgress, .inProgress): true
        case (.unknown(let ld), .unknown(let rd)): ld == rd
        case (.warning(let ld, let lo), .warning(let rd, let ro)):
            if let lo, let ro {
                ld == rd && lo.id == ro.id
            } else if lo == nil && ro == nil {
                ld == rd
            } else { false }
        case (.error(let ld, let lo), .error(let rd, let ro)):
            if let lo, let ro {
                ld == rd && lo.id == ro.id
            } else if lo == nil && ro == nil {
                ld == rd
            } else { false }
        default: false
        }
    }
    
    case unknown(description: String)
    case actual
    case waiting
    case inProgress
    case warning(description: String, operation: (any EnvironmentItemOperation)?)
    case error(description: String, operation: (any EnvironmentItemOperation)?)
}

public protocol EnvironmentItemOperation: Equatable, Identifiable, Sendable {
    var id: Int { get }
    var title: String { get }
    func operation(_: CommandExecutor, _: Logger) async throws(EnvironmentItemOperationError) -> Void
}

public struct EnvironmentItemOperationError: LocalizedError {
    public var errorDescription: String
    public var operation: (any EnvironmentItemOperation)?
    
    public init(errorDescription: String, operation: (any EnvironmentItemOperation)? = nil) {
        self.errorDescription = errorDescription
        self.operation = operation
    }
}

public extension EnvironmentItemOperation {
    var id: Int {
        title.hashValue
    }
}

/// Preset Environment Object - Xcode Development Environment
public struct XcodeEnvironmentItem: EnvironmentItem {
    
    private let needVersion: String
    private let allowHighVersion: Bool
    
    public let title = "Xcode"
    public var status: Status = .unknown(description: "Проверка состояния еще не проведена")
    
    public init(needVersion: String, allowHighVersion: Bool) {
        self.needVersion = needVersion
        self.allowHighVersion = allowHighVersion
    }
    
    public func calculateStatus(_ commandExecutor: CommandExecutor, _ logger: Logger) async -> Status {
        do {
            let rawVersionInfo = try await commandExecutor.execute(сommandWithSingleOutput: "xcodebuild -version").split(separator: " ")
            guard rawVersionInfo.count > 1 else {
                let message = "Некорректный результат команды xcodebuild -version. Используйте xcode-select для указания пути к актуальному Xcode"
                Task {
                    await logger.log(.debug, message: message)
                }
                throw MagicError(errorDescription: message)
            }
            let currentXcodeVersion = rawVersionInfo[1]
            return if currentXcodeVersion == needVersion {
                .actual
            } else if currentXcodeVersion > needVersion, allowHighVersion {
                .actual
            } else {
                .error(description: "Используется неверная версия Xcode. Требуется \(needVersion), установлена \(currentXcodeVersion)", operation: nil)
            }
        } catch {
            return .unknown(description: "Не удалось проверить состояние зависимости. Ошибка - \(error.localizedDescription)")
        }
    }
}

/// Preset environment object - macOS Operating System
public struct MacOsEnvironmentItem: EnvironmentItem {
    
    private let needVersion: String
    private let allowHighVersion: Bool
    
    public let title = "MacOS"
    public var status: Status = .unknown(description: "Проверка состояния еще не проведена")
    
    public init(needVersion: String, allowHighVersion: Bool) {
        self.needVersion = needVersion
        self.allowHighVersion = allowHighVersion
    }
    
    public func calculateStatus(_ commandExecutor: CommandExecutor, _ logger: Logger) async -> Status {
        do {
            let version = try await commandExecutor.execute(сommandWithSingleOutput: "sw_vers -productVersion")
            return if version == needVersion {
                .actual
            } else if version > needVersion, allowHighVersion {
                .actual
            } else {
                .error(description: "У вас установлена неверная версия macOS. Требуется \(needVersion), установлена \(version)", operation: nil)
            }
        } catch {
            return .unknown(description: "Не удалось проверить состояние зависимости. Ошибка - \(error.localizedDescription)")
        }
    }
}

// MARK: - Integration with GIT

/// Support for GIT integration
public protocol GitSupported: IProjectService {
    /// Наблюдать за изменение ветки
    var gitBranchObservation: Bool { get }
}

// MARK: - Quick Operations

/// Quick Operations Support
///
/// When signing to a protocol, the Operations section appears in the main menu
public protocol QuickOperationSupported: IProjectService {
    /// Метод возвращает секции и операции внутри секций
    @MainActor
    func operations(console: IConsole) -> [CustomActionSection]
}

// MARK: - Custom generation settings

/// Support for custom generation settings on the "Generation settings" screen
///
/// By default, the user has access to general generation settings. A signature on this protocol allows you to specify
/// custom settings to change the generation scenario
public protocol GenerateConfigurationSupported: IProjectService {
    var isSupportedGenerationWithExternalConsole: Bool { get }
    @MainActor
    func configurationView(onChange: @escaping () -> Void) -> AnyView
}

public extension GenerateConfigurationSupported {
    var isSupportedGenerationWithExternalConsole: Bool { false }
}

// MARK: - CodeOwners

/// Support for working with CodeOwners service
///
/// When signing for a protocol
/// - a section "CodeOwners" appears in the main menu
/// - a section with module owners appears on the module screen (if there is a signature for the ModuleScreenSupported protocol)
public protocol CodeOwnersSupported: IProjectService {
    /// Absolute path to file with code owners data. Ussualy named `codeowners.json`
    var codeOwnersFileAbsolutePath: String { get }
    /// Fetcher for users data
    var codeOnwersDeveloperTeamMemberInfoFetcher: DeveloperTeamMemberInfoFetcher { get }
}

public extension CodeOwnersSupported {
    var codeOwnersFileAbsolutePath: String {
        self.projectURL.appending(path: "codeowners.json").path()
    }
}

// MARK: - CodeStyler

/// Support for working with CodeStyler service
///
/// When signing for a protocol
/// - a section "CodeStyler" appears in the main menu
public protocol CodeStylerSupported: IProjectService {
    /// The branch relative to which the diff is calculated. Usually this is `main` or `master`
    var codeStylerTargetGitBranch: String { get }
    /// List of files diff checkers
    var codeStylerFilesDiffCheckers: [any IFilesDiffChecker] { get }
    /// File names containing these words will be excluded from the analysis. Usually use `Generated`
    var codeStylerExcludeFilesWithNameContaints: [String] { get }
}

// MARK: - Module screen

/// Module screen support
///
/// When signing for a protocol, display a button in the module table to go to the screen for additional information about the module
/// When signing for a protocol
/// - a "Code Owners" section appears in the main menu
/// - a section with module owners appears on the module screen (if there is a signature for the ModuleScreenSupported protocol)
public protocol ModuleScreenSupported: IProjectService {
    /// The method returns sections and operations within sections for output in the right panel
    @MainActor
    func moduleScreenAdditionalOperations(module: any IProjectModule, console: IConsole) -> [CustomActionSection]?
    
    /// The method returns an additional View, which is placed immediately after the general information about the module
    @MainActor
    func moduleScreenAdditionalView(module: Binding<any IProjectModule>) -> AnyView?
}

public extension ModuleScreenSupported {
    @MainActor
    func moduleScreenAdditionalOperations(module: any IProjectModule, console: IConsole) -> [CustomActionSection]? { nil }
    
    @MainActor
    func moduleScreenAdditionalView(module: Binding<any IProjectModule>) -> AnyView? { nil }
}

// MARK: - Filtering modules on the modules page

public protocol ModulesFilterSupported: IProjectService {
    /// Initial values ​​of filter sections
    ///
    /// During project initialization, these values ​​are initialized in projectViewModel
    var initialModulesFilterSections: [FilterSection] { get }
}

/// Describes a section in the filters section
public struct FilterSection: Identifiable {
    public let id = UUID()
    public let title: String
    public let description: String
    public var values: [any FilterValue]
    
    public init(title: String, description: String, values: [any FilterValue]) {
        self.title = title
        self.description = description
        self.values = values
    }
}

/// General protocol for working with specific filters
///
/// For a specific implementation, use successor protocols (for example, FilterToggle, FilterPicker ...)
public protocol FilterValue: Identifiable, Hashable {
    func filter(module: any IProjectModule) -> Bool
}
public extension FilterValue {
    var id: Int { self.hashValue }
}

/// Toggle filter model
public protocol FilterToggle: FilterValue {
    var name: String { get }
    var description: String? { get }
    var currentValue: Bool { get set }
}

/// Filter model in the form of a picker with a drop-down list
public protocol FilterPicker: FilterValue {
    var name: String { get }
    var description: String? { get }
    var currentValue: String { get set }
    var values: [String] { get }
}
