//
//  CEFV8ContextSafetyImplementation.swift
//  CEF.swift
//
//  Created by Tamas Lustyik on 2015. 08. 03..
//  Copyright © 2015. Tamas Lustyik. All rights reserved.
//

import Foundation

public enum CEFV8ContextSafetyImplementation: Int {
    case Default = 0
    case Alternate = 1
    case Disabled = -1
}

extension CEFV8ContextSafetyImplementation {
    func toCEF() -> Int32 {
        return Int32(rawValue)
    }
}