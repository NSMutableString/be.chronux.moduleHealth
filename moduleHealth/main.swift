//
//  main.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 13/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

private func printUsage() {
    print("moduleHealth -m <MODULES-JSON> -csv <FILE-NAME>")
    print("version 1.0.0")
    print("")
    print("-m: a JSON with a module name and the local path to it.")
    print("-csv: create a CSV with all relevant data")
}

let argumentsParser = ArgumentsParser(arguments: CommandLine.arguments)
let commands = try argumentsParser.run()
var csvGenerator: CsvGenerator?

let moduleCommand = commands.first { $0.key == CommandKey.moduleJson }
guard let jsonModules = moduleCommand?.value else {
    printUsage()
    exit(1)
}
guard let modules = JsonHandler<[Module]>().parse(filePath: jsonModules) else {
    print("no module names and paths could be parsed from given configuration.")
    exit(1)
}
let csvCommand = commands.first { $0.key == CommandKey.csvFileName }
if let csvFileName = csvCommand?.value {
    csvGenerator = CsvGenerator(fileName: csvFileName)
}

var allDependencies = [String: [String]]()
for module in modules {
    let moduleHealth = ModuleHealth(module: module)
    let dependencies = moduleHealth.getOutgoingDependencies()
    allDependencies[module.name] = dependencies
}

for module in modules {
    let moduleHealth = ModuleHealth(module: module)
    let abstractnessScore = moduleHealth.validateStableAbstractionsPrinciple()
    let stabilityScore = moduleHealth.validateStableDependenciesPrinciple(allDependencies: allDependencies)
    let distance = moduleHealth.distanceFromMainSequence(abstractnessScore: abstractnessScore, stabilityScore: stabilityScore)

    print("\(ANSIColors.yellow.rawValue)module abstractness score = \(abstractnessScore)")
    print("\(ANSIColors.yellow.rawValue)module stability score = \(stabilityScore)")
    if distance > 0.5 {
        print("\(ANSIColors.magenta.rawValue)\(module.name)\(ANSIColors.default.rawValue) - \(ANSIColors.yellow.rawValue)module distance = \(ANSIColors.red.rawValue)\(distance)")
    }
    else {
        print("\(ANSIColors.magenta.rawValue)\(module.name)\(ANSIColors.default.rawValue) - \(ANSIColors.yellow.rawValue)module distance = \(distance)")
    }

    if csvCommand?.value != nil {
        csvGenerator?.writeLine(moduleName: module.name, abstractnessScore: abstractnessScore, stabilityScore: stabilityScore, distance: distance)
        csvGenerator?.writeFileToCurrentFolder()
    }
}

print("\(ANSIColors.default.rawValue)Done")
