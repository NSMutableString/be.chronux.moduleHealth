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

    func validate() -> Int {

        var publicProtocolList = [String]()
        var publicImplementationList = [String]()

        let enumerator = FileManager.default.enumerator(atPath: moduleName)

        while let element = enumerator?.nextObject() as? String {
            guard !element.hasPrefix("Carthage/") else { continue }
            if element.hasSuffix("swift") {
                print("\(ANSIColors.green.rawValue)validated - \(ANSIColors.default.rawValue)\(element)")

                let result = readFile(filePath: "\(moduleName)/\(element)")

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

    private func readFile(filePath: String) -> (isAbstact: Bool, isImplementation: Bool) {
        do {

            let contents = try String(contentsOfFile: filePath, encoding: .utf8)

            var isAbstract = false
            var isImplementation = false

            if contents.contains("public extension") {
                isAbstract = true
            }

            if contents.contains("public struct") || contents.contains("public class") {
                isImplementation = true
            }

            return (isAbstract, isImplementation)
        }
        catch let error as NSError {
            print("Error reading file: \(error)")
            return (false, false)
        }
    }
}
