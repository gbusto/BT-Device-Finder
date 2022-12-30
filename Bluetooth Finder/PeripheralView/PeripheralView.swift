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
                RssiView(peripheral: peripheral,
                         rssiReadings: $centralManager.rssiReadings,
                         rssiHelper: rssiHelper)
                
                PeripheralConnectionView(isConnected: centralManager.isConnectedToDevice(peripheral))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("\(centralManager.getPeripheralName(peripheral))")
        .onAppear {
            centralManager.requestFullDiscovery(forPeripheral: peripheral)
        }
    }
}

struct PeripheralConnectionView: View {
    var isConnected: Bool
    
    var body: some View {
        if isConnected {
            Text("Successfully connected to device!")
        }
        else {
            Text("Unable to connect to device")
        }
    }
}

struct RssiView: View {
    var peripheral: CBPeripheral
    @Binding var rssiReadings: [UUID: Int]
    var rssiHelper: RssiHelper
    
    var body: some View {
        Image(rssiHelper.getImageNameFor(getRssiForPeripheral(peripheral)))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 250)
    }
    
    func getRssiForPeripheral(_ peripheral: CBPeripheral) -> Int {
        if let rssi = rssiReadings[peripheral.identifier] {
            return rssi
        }
        
        return 0
    }
}
