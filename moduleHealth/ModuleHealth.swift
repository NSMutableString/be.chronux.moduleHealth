//
//  ModuleHealth.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 14/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

struct ModuleHealth {

    private let moduleName: String

    init(moduleName: String) {
        self.moduleName = moduleName
    }

    /// Stable dependencies principle
    /// - depend in the direction of stability
    /// - metric ranges from 0 to 1
    /// - A value of 0 indicates a maximally stable module. A value of 1 indicates a maximally unstable component
    func validateStableDependenciesPrinciple() -> Int {
        let allDependencies = [
            "module_1": ["module_2", "module_3"],
            "module_2": ["module_3"]
        ]
        let incomingDependencies = getIncomingDependencies(allDependencies: allDependencies)
        let outgoingDependencies = getOutgoingDependencies().count
        if incomingDependencies + outgoingDependencies == 0 {
            return 0
        }

        print("\(ANSIColors.green.rawValue)stability \(ANSIColors.default.rawValue)- incoming dependencies = \(incomingDependencies)")
        print("\(ANSIColors.green.rawValue)stability \(ANSIColors.default.rawValue)- outgoing dependencies = \(outgoingDependencies)")

        return outgoingDependencies / ( incomingDependencies + outgoingDependencies )
    }

    private func getIncomingDependencies(allDependencies: [String: [String]]) -> Int {
        var incomingDependenciesCount = 0
        for dependency in allDependencies {
            if dependency.value.contains(moduleName) {
                incomingDependenciesCount += 1
            }
        }
        return incomingDependenciesCount
    }

    /// Get the used dependencies by parsing the `Cartfile`
    func getOutgoingDependencies() -> [String] {
        let content = readFile(filePath: "\(moduleName)/Cartfile")

        let carthageContent = content as NSString

        var dependencies = [String]()
        carthageContent.enumerateLines { (line, _) in
            dependencies.append(line)
        }

        return dependencies
    }

    /// Stable abstractions principle
    /// - a component should be as abstract as it is stable
    /// - metric ranges from 0 to 1
    /// - A value of 0 implies that the component has no abstract class at all. A value of 1 implies that the component contains nothing but abstract classes
    func validateStableAbstractionsPrinciple() -> Float {

        var scannedSwiftFilesCount = 0
        var publicAbstractionsList = [String]()
        var publicImplementationList = [String]()

        let enumerator = FileManager.default.enumerator(atPath: moduleName)

        while let element = enumerator?.nextObject() as? String {
            guard !element.hasPrefix("Carthage/") else { continue }
            if element.hasSuffix("swift") {
                scannedSwiftFilesCount += 1
                let content = readFile(filePath: "\(moduleName)/\(element)")

                if containsAbstractImplementation(content: content) {
                    publicAbstractionsList.append(element)
                }
                if containsConcreteImplementation(content: content) {
                    publicImplementationList.append(element)
                }
            }
        }

        print("\(ANSIColors.green.rawValue)abstractness \(ANSIColors.default.rawValue)- scanned swift files = \(scannedSwiftFilesCount)")
        print("\(ANSIColors.green.rawValue)abstractness \(ANSIColors.default.rawValue)- abstractions = \(publicAbstractionsList.count)")
        print("\(ANSIColors.green.rawValue)abstractness \(ANSIColors.default.rawValue)- implementations = \(publicImplementationList.count)")

        if publicImplementationList.count == 0 {
            return 1
        }
        return Float(publicAbstractionsList.count) / Float(publicImplementationList.count)
    }

    private func containsAbstractImplementation(content: String) -> Bool {
        var isAbstract = false

        if content.contains("public protocol") {
            isAbstract = true
        }

        return isAbstract
    }

    private func containsConcreteImplementation(content: String) -> Bool {
        var isConcreteImplementation = false

        if content.contains("public struct") || content.contains("public class") {
            isConcreteImplementation = true
        }

        return isConcreteImplementation
    }

    private func readFile(filePath: String) -> String {
        do {
            return try String(contentsOfFile: filePath, encoding: .utf8)
        }
        catch let error as NSError {
            print("Error reading file: \(error)")
            return ""
        }
    }
}
