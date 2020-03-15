//
//  main.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 13/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

private func printUsage() {
    print("moduleHealth -m <MODULE-NAME>")
    print("version 1.0.0")
    print("")
    print("MODULE-NAME: the name of the module")
}

let argumentsParser = ArgumentsParser(arguments: CommandLine.arguments)

let commands = try argumentsParser.run()

let moduleCommand = commands.first { $0.key == CommandKey.moduleName }
let moduleName = moduleCommand!.value

let moduleHealth = ModuleHealth(moduleName: moduleName)
let abstractnessScore = moduleHealth.validateStableAbstractionsPrinciple()
let stabilityScore = moduleHealth.validateStableDependenciesPrinciple()

print("\(ANSIColors.yellow.rawValue)module abstractness score = \(abstractnessScore)")
print("\(ANSIColors.yellow.rawValue)module stability score = \(stabilityScore)")
print("\(ANSIColors.default.rawValue)Done")
