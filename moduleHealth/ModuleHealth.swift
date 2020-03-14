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
        return 0
    }
}
