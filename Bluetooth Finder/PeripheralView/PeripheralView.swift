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
    
    @EnvironmentObject public var centralManager: CentralManager
    
    public var deviceId: UUID
    public var deviceName: String
        
    var rssiHelper: RssiHelper = RssiHelper()
                
    var body: some View {
        ZStack {
            LinearGradient(colors: [.bgDark1, .bgDark2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack {
                RssiView(deviceId: deviceId,
                         rssiReadings: $centralManager.rssiReadings,
                         rssiHelper: rssiHelper)
                
                PeripheralConnectionView(isConnected: centralManager.isConnectedToDevice(deviceId))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("\(deviceName)")
        .onAppear {
            centralManager.requestFullDiscovery(forPeripheralWithId: deviceId)
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
    var deviceId: UUID
    @Binding var rssiReadings: [UUID: Int]
    var rssiHelper: RssiHelper
    
    var body: some View {
        Image(rssiHelper.getImageNameFor(getRssiForPeripheral(deviceId)))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: 250)
    }
    
    func getRssiForPeripheral(_ deviceId: UUID) -> Int {
        if let rssi = rssiReadings[deviceId] {
            return rssi
        }
        
        return 0
    }
}
