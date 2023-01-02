//
//  PeripheralView.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import Foundation
import SwiftUI

struct Device: Identifiable, Hashable {
    var id: UUID
    var name: String
    var state: Int
}

struct PeripheralView: View {
    
    @EnvironmentObject public var centralManager: CentralManager
    
    public var device: Device
        
    var rssiHelper: RssiHelper = RssiHelper()
                
    var body: some View {
        ZStack {
            LinearGradient(colors: [.bgDark1, .bgDark2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack {
                RssiView(device: device,
                         rssiReadings: $centralManager.rssiReadings,
                         rssiHelper: rssiHelper)
                
                PeripheralConnectionView(isConnected: centralManager.isConnectedToDevice(device.id))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationTitle("\(device.name))")
        .onAppear {
            centralManager.requestFullDiscovery(forPeripheralWithId: device.id)
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
    var device: Device
    @Binding var rssiReadings: [UUID: Int]
    var rssiHelper: RssiHelper
    
    var body: some View {
        Image(rssiHelper.getImageNameFor(getRssiForPeripheral(device.id)))
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
