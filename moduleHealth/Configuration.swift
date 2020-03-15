//
//  Configuration.swift
//  mergeRequestScanner
//
//  Created by Bram Huenaerts on 13/03/2020.
//  Copyright © 2020 chronux bv. All rights reserved.
//

import Foundation

struct Module: Codable {
    let name: String
    let path: String
}

struct JsonHandler<T: Decodable> {

    func parse(filePath: String) -> T? {
        guard let fileContent = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return nil
        }

        // In case of a problem with the JSON, please crash and show me :-)
        return try! JSONDecoder().decode(T.self, from: fileContent)
    }
}
