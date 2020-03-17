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

let isLoggingEnabled = false
let enableScatterPlot = true

for module in modules {
    let moduleHealth = ModuleHealth(modulePath: module.path, moduleName: module.name)
    let abstractnessScore = moduleHealth.validateStableAbstractionsPrinciple(isLoggingEnabled: isLoggingEnabled)
    let stabilityScore = moduleHealth.validateStableDependenciesPrinciple(allDependencies: allDependencies, isLoggingEnabled: isLoggingEnabled)
    let distance = moduleHealth.distanceFromMainSequence(abstractnessScore: abstractnessScore, stabilityScore: stabilityScore)

    if isLoggingEnabled {
        print("\(ANSIColors.yellow.rawValue)module abstractness score = \(abstractnessScore)")
        print("\(ANSIColors.yellow.rawValue)module stability score = \(stabilityScore)")
        if distance > 0.5 {
            print("\(ANSIColors.magenta.rawValue)\(module.name)\(ANSIColors.default.rawValue) - \(ANSIColors.yellow.rawValue)module distance = \(ANSIColors.red.rawValue)\(distance)")
        }
        else {
            print("\(ANSIColors.magenta.rawValue)\(module.name)\(ANSIColors.default.rawValue) - \(ANSIColors.yellow.rawValue)module distance = \(distance)")
        }
    }
    if enableScatterPlot {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let formattedAbstractnessScore = formatter.string(from: NSNumber(value: abstractnessScore))
        let formattedStabilityScore = formatter.string(from: NSNumber(value: stabilityScore))
        print("\(ANSIColors.magenta.rawValue)\(module.name)\(ANSIColors.default.rawValue);\(ANSIColors.yellow.rawValue)\(formattedStabilityScore ?? "");\(formattedAbstractnessScore ?? "")")
    }
}

print("\(ANSIColors.default.rawValue)Done")
