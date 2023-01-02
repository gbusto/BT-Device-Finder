//
//  CommonColors.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/30/22.
//

import Foundation
import SwiftUI

extension Color {
    public static var random: Color {
        return Color(cgColor: CGColor(red: CGFloat.random(in: 0..<1),
                                      green: CGFloat.random(in: 0..<1),
                                      blue: CGFloat.random(in: 0..<1),
                                      alpha: 1))
    }
    
    public static var bgDark1: Color {
        return Color(cgColor: CGColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1))
    }
    
    public static var bgDark2: Color {
        return Color(cgColor: CGColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1))
    }
}
