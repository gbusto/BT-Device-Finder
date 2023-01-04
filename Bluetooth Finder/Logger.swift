//
//  Logger.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/30/22.
//

import Foundation
import OSLog

class Logger {
    
    public enum PrintLevel {
        case TRACE
        case DEBUG
        case INFO
        case ERROR
        case FATAL
    }
    
    static public func print(_ items: Any..., separator: String = " ", terminator: String = "\n", level: PrintLevel = .DEBUG) {
        #if DEBUG
        debugPrint(items, separator: separator, terminator: terminator)
        #endif
    }
}
