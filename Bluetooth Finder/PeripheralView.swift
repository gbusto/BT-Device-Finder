//
//  PeripheralView.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct PeripheralView: View {
    
    @ObservedObject public var centralManager: CentralManager
    
    public var peripheral: CBPeripheral
    
    @State var backgroundColor: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            
    var body: some View {
        ZStack {
            Color(backgroundColor)
            
            VStack {
                AppButton(text: "Read RSSI", action: readRssi)
                
                RssiView(rssi: $centralManager.targetRssi)
            }
        }
        .onAppear {
            centralManager.connectToDevice(peripheral)
        }
        .onDisappear {
            centralManager.disconnectFromDevice(peripheral)
        }
    }
    
    func readRssi() {
        centralManager.readRssi(peripheral)
    }
}

struct RssiView: View {
    @Binding var rssi: Int
    
    var body: some View {
        Text("RSSI is now \(rssi)")
    }
}
