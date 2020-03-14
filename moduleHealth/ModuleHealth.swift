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

    func getIncomingDependencies() -> Int {
        // todo: check if we should use Cartfile.resolved or Cartfile (number of lines should be ok)
        let content = readFile(filePath: "\(moduleName)/Cartfile")

        let carthageContent = content as NSString

        var lineCount = 0
        carthageContent.enumerateLines { (line, _) in
            lineCount += 1
        }

        return lineCount

    }

    func validate() -> Int {

        var publicProtocolList = [String]()
        var publicImplementationList = [String]()

        let enumerator = FileManager.default.enumerator(atPath: moduleName)

        while let element = enumerator?.nextObject() as? String {
            guard !element.hasPrefix("Carthage/") else { continue }
            if element.hasSuffix("swift") {
                print("\(ANSIColors.green.rawValue)validated - \(ANSIColors.default.rawValue)\(element)")

                let content = readFile(filePath: "\(moduleName)/\(element)")
                let result = validateAbstraction(content: content)

                if result.isAbstact {
                    publicProtocolList.append(element)
                }
                if result.isImplementation {
                    publicImplementationList.append(element)
                }
            }
        }

        print("\(ANSIColors.default.rawValue)found abstractions = \(publicProtocolList.count)")
        print("\(ANSIColors.default.rawValue)found implementations = \(publicImplementationList.count)")

        return publicProtocolList.count / publicImplementationList.count
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

    private func validateAbstraction(content: String) -> (isAbstact: Bool, isImplementation: Bool) {
        var isAbstract = false
        var isImplementation = false

        if content.contains("public extension") {
            isAbstract = true
        }

        if content.contains("public struct") || content.contains("public class") {
            isImplementation = true
        }

        return (isAbstract, isImplementation)
    }
}
