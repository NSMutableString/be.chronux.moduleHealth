//
//  ModuleHealth.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 14/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

struct ModuleHealth {

    private let modulePath: String
    private let moduleName: String

    init(modulePath: String, moduleName: String) {
        self.modulePath = modulePath
        self.moduleName = moduleName
    }

    /// Used to create a scatterplot of the modules
    /// - a value of 0 indicates that the module is directly on the main sequence
    /// - a value of 1 indicates that the module is as far aways as possible from the main sequence
    func distanceFromMainSequence(abstractnessScore: Float, stabilityScore: Float) -> Float {
        return abs(abstractnessScore + stabilityScore - 1)
    }

    /// Stable dependencies principle
    /// - depend in the direction of stability
    /// - metric ranges from 0 to 1
    /// - A value of 0 indicates a maximally stable module. A value of 1 indicates a maximally unstable component
    func validateStableDependenciesPrinciple(allDependencies: [String: [String]]) -> Float {
        let incomingDependencies = getIncomingDependencies(allDependencies: allDependencies)
        let outgoingDependencies = getOutgoingDependencies().count
        if incomingDependencies + outgoingDependencies == 0 {
            print("\(ANSIColors.green.rawValue)stability \(ANSIColors.default.rawValue)- no dependencies")
            return 0
        }

        print("\(ANSIColors.green.rawValue)stability \(ANSIColors.default.rawValue)- incoming dependencies = \(incomingDependencies)")
        print("\(ANSIColors.green.rawValue)stability \(ANSIColors.default.rawValue)- outgoing dependencies = \(outgoingDependencies)")

        return Float(outgoingDependencies) / ( Float(incomingDependencies) + Float(outgoingDependencies) )
    }

    private func getIncomingDependencies(allDependencies: [String: [String]]) -> Int {
        var incomingDependenciesCount = 0
        for dependency in allDependencies {

            let filteredDependencies = dependency.value.filter { (item: String) -> Bool in
                let stringMatch = item.lowercased().range(of: moduleName.lowercased())
                return stringMatch != nil ? true : false
            }

            if !filteredDependencies.isEmpty {
                incomingDependenciesCount += 1
            }
        }
        return incomingDependenciesCount
    }

    /// Get the used dependencies by parsing the `Cartfile`
    func getOutgoingDependencies() -> [String] {
        let content = readFile(filePath: "\(modulePath)/Cartfile")

        let carthageContent = content as NSString

        var dependencies = [String]()
        carthageContent.enumerateLines { (line, _) in
            guard !line.hasPrefix("#") && !line.isEmpty else { return }
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

        let enumerator = FileManager.default.enumerator(atPath: modulePath)

        while let element = enumerator?.nextObject() as? String {
            guard !element.hasPrefix("Carthage/") else { continue }
            if element.hasSuffix("swift") {
                scannedSwiftFilesCount += 1
                let content = readFile(filePath: "\(modulePath)/\(element)")

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
