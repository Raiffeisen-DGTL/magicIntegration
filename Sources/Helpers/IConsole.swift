//
//  IConsole.swift
//  RaifMagic
//
//  Created by USOV Vasily on 18.02.2025.
//

import CommandExecutor

/// Console that can be passed to viewModels and other places, so as not to pass consoleViewModel as is
public protocol IConsole: Sendable {
    @discardableResult
    func run(work: @Sendable @escaping (IConsole) async throws -> Void,
             withTitle title: String?,
             outputStrategy: [PublishMessagesStrategy]) async -> Bool
    @discardableResult
    func run(textCommand: String,
             atPath: String?,
             withTitle: String?,
             convertErrorToWarning: Bool,
             outputStrategy: [PublishMessagesStrategy]) async  -> Bool
    @discardableResult
    func run(command: Command,
             withTitle: String?,
             convertErrorToWarning: Bool,
             outputStrategy: [PublishMessagesStrategy]) async -> Bool
    @discardableResult
    func run(scenario: CommandScenario,
             outputStrategy: [PublishMessagesStrategy]) async -> Bool
    var isCommandRunning: Bool { get async }
    var needShowConsole: Bool { get async }
    func addConsoleOutput(line: ConsoleLine) async
    func addConsoleOutput(lines: [ConsoleLine]) async
    func addConsoleOutput(content: String, color: ConsoleLineItem.Color) async
    func addEmptyLine() async
}

/// Command event publishing strategy
public enum PublishMessagesStrategy: CaseIterable, Sendable {
    /// Print the command being called
    case command
    /// Print command output
    case commandOutput
    /// Add a blank line before the command output
    case emptyLinePrefix
    /// Auxiliary header messages and execution results
    case information
    /// Error information as a result of execution
    case error
}

public extension [PublishMessagesStrategy] {
    static var all: [PublishMessagesStrategy] {
        PublishMessagesStrategy.allCases
    }
}
