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
        
    var rssiHelper: RssiHelper = RssiHelper()
            
    var body: some View {
        ZStack {
            RssiView(rssi: $centralManager.targetRssi, rssiHelper: rssiHelper)
            
            VStack {
                Text("RSSI: \(rssiHelper.translateRssi(centralManager.targetRssi))")
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                PeripheralConnectionView(attemptedConnect: $centralManager.attemptedConnect,
                                         errorConnecting: $centralManager.errorConnecting)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            centralManager.connectToDevice(peripheral)
        }
        .onDisappear {
            centralManager.disconnectFromDevice(peripheral)
            centralManager.reset()
        }
    }
}

struct PeripheralConnectionView: View {
    @Binding var attemptedConnect: Bool
    @Binding var errorConnecting: Bool
    
    var body: some View {
        if attemptedConnect && !errorConnecting {
            Text("Successfully connected to device!")
        }
        else if attemptedConnect && errorConnecting {
            Text("Failed to connect to device")
        }
        else {
            Text("Attemping to connect to device...")
        }
    }
}

struct RssiView: View {
    @Binding var rssi: Int
    var rssiHelper: RssiHelper
    
    var body: some View {
        Color(cgColor: rssiHelper.getColorFor(rssi))
    }
}
