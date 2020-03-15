//
//  main.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 13/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

private func printUsage() {
    print("moduleHealth -m <MODULES-JSON>")
    print("version 1.0.0")
    print("")
    print("MODULES-JSON: a JSON with a module name and the local path to it.")
}

let argumentsParser = ArgumentsParser(arguments: CommandLine.arguments)
let commands = try argumentsParser.run()

let moduleCommand = commands.first { $0.key == CommandKey.moduleJson }
guard let jsonModules = moduleCommand?.value else {
    printUsage()
    exit(1)
}
guard let modules = JsonHandler<[Module]>().parse(filePath: jsonModules) else {
    print("no module names and paths could be parsed from given configuration.")
    exit(1)
}

var allDependencies = [String: [String]]()
for module in modules {
    let moduleHealth = ModuleHealth(modulePath: module.path, moduleName: module.name)
    let dependencies = moduleHealth.getOutgoingDependencies()
    allDependencies[module.name] = dependencies
}

for module in modules {
    let moduleHealth = ModuleHealth(modulePath: module.path, moduleName: module.name)
    let abstractnessScore = moduleHealth.validateStableAbstractionsPrinciple()
    let stabilityScore = moduleHealth.validateStableDependenciesPrinciple(allDependencies: allDependencies)
    let distance = moduleHealth.distanceFromMainSequence(abstractnessScore: abstractnessScore, stabilityScore: stabilityScore)

    print("\(ANSIColors.yellow.rawValue)module abstractness score = \(abstractnessScore)")
    print("\(ANSIColors.yellow.rawValue)module stability score = \(stabilityScore)")
    print("\(ANSIColors.yellow.rawValue)module distance = \(distance)")
    print("\(ANSIColors.default.rawValue)Done")
}
