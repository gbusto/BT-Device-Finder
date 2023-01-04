//
//  CommonViews.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 1/2/23.
//

import Foundation
import SwiftUI

struct StateButton: View {
    @Binding var state: Bool
    
    var activeText: String
    var inactiveText: String
    
    var action: () -> Void
    
    var body: some View {
        AppButton(text: state ? activeText : inactiveText,
                  action: action)
    }
}

struct AppButton: View {
    var text: String
    
    var action: () -> Void
    
    var body: some View {
        Button(text, action: action)
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
    }
}

struct BackgroundColor: View {
    var body: some View {
        LinearGradient(colors: [.bgDark1, .bgDark2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
    }
}
