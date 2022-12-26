//
//  ContentView.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import SwiftUI
import CoreData
import CoreBluetooth

struct ContentView: View {
    
    @ObservedObject var centralManager: CentralManager = CentralManager()

    var body: some View {
        NavigationStack {
            VStack {
                StateButton(state: $centralManager.isScanning,
                            activeText: "Stop Scanning",
                            inactiveText: "Start Scanning",
                            action: updateScanState)
                
                DevicesList(btManager: centralManager,
                            _devices: $centralManager.devices)
            }
        }
        .onAppear {
            centralManager.start()
        }
    }
    
    func updateScanState() {
        if centralManager.isScanning {
            centralManager.stopScanning()
        }
        else {
            centralManager.startScanning()
        }
    }
}

struct DevicesList: View {
    var btManager: CentralManager
    @Binding var _devices: Set<CBPeripheral>
    
    var body: some View {
        ScrollView {
            ForEach(Array(_devices), id: \.self) { device in
                DeviceView(btManager: btManager,
                           device: device,
                           textColor: .red)
            }
        }
        .padding()
    }
}

struct DeviceView: View {
    var btManager: CentralManager
    var device: CBPeripheral
    var textColor: Color
    var maxStringLength: Int = 20
    
    var body: some View {
        NavigationLink("Name: \(truncatedName(name: device.name ?? device.identifier.uuidString))",
                       destination: PeripheralView(centralManager: btManager,
                                                   peripheral: device))
            .foregroundColor(.red)
    }
    
    func truncatedName(name: String) -> String {
        if name.count > maxStringLength {
            let start = name.startIndex
            let end = name.index(start, offsetBy: maxStringLength - 3)
            let _name = name[start..<end]
            return String(_name + "...")
        }
        
        return name
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
