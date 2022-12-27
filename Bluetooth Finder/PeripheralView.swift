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
            LinearGradient(colors: [.bgDark1, .bgDark2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack {
                RssiView(rssi: $centralManager.targetRssi, rssiHelper: rssiHelper)
                
                PeripheralConnectionView(attemptedConnect: $centralManager.attemptedConnect,
                                         errorConnecting: $centralManager.errorConnecting)
                .foregroundColor(.white)
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
        Image(rssiHelper.getImageNameFor(rssi))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
