//
//  Arguments.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 13/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

enum ArgumentsParserError: Error {
    case noArgumentsError
    case moduleNotSpecifiedError
}

enum CommandKey: String {
    case moduleName = "-m"
}

struct ArgumentsParser {

    let arguments: [String]

    init(arguments: [String]) {
        self.arguments = arguments
    }

    func run() throws -> [Command] {
        try validate()
        return parseCommandsFromArguments()
    }

    private func validate() throws {
        guard !arguments.dropFirst().isEmpty else {
            throw ArgumentsParserError.noArgumentsError
        }
        guard arguments.contains(CommandKey.moduleName.rawValue) else {
            throw ArgumentsParserError.moduleNotSpecifiedError
        }
    }

    private func parseCommandsFromArguments() -> [Command] {
        var commands = [Command]()
        let allArgumentsExceptFirstReversed = arguments.dropFirst().reversed()
        var commandValues = [String]()
        for argument in allArgumentsExceptFirstReversed {
            let commandKey = CommandKey(rawValue: argument)
            guard let aCommandKey = commandKey else {
                commandValues.append(argument)
                continue
            }
            let aCommand = Command(key: aCommandKey, value: commandValues.first!)
            commands.append(aCommand)
            commandValues = [String]()
        }
        return commands
    }
}

struct Command {
    let key: CommandKey
    let value: String
}
