//
//  Logger.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/30/22.
//

import Foundation

class Logger {
    
    static public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        debugPrint(items, separator: separator, terminator: terminator)
        #endif
    }
    
}
