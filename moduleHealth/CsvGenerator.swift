//
//  CsvGenerator.swift
//  moduleHealth
//
//  Created by Bram Huenaerts on 17/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

struct CsvGenerator {

    let fileName: String
    var buffer: String

    init(fileName: String) {
        self.fileName = fileName
        buffer = ""
    }

    mutating func writeLine(moduleName: String, abstractnessScore: Float, stabilityScore: Float, distance: Float) {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let formattedStabilityScore = formatter.string(from: NSNumber(value: stabilityScore))
        let formattedAbstractnessScore = formatter.string(from: NSNumber(value: abstractnessScore))
        let formattedDistance = formatter.string(from: NSNumber(value: distance))

        buffer.append("\(moduleName);\(formattedAbstractnessScore ?? "NA");\(formattedStabilityScore ?? "NA");\(formattedDistance ?? "NA")\n")
    }

    func writeFileToCurrentFolder() {
        writeFileToCurrentFolder(buffer: buffer, fileName: fileName)
    }

    private func writeFileToCurrentFolder(buffer: String, fileName: String) {
        let currentDirectory = FileManager.default.currentDirectoryPath
        let filePath = "\(currentDirectory)/\(fileName)"
        try? buffer.write(to: URL(fileURLWithPath: filePath), atomically: false, encoding: .utf8)
    }
}
