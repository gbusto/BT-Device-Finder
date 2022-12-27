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
    
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.bgDark1, .bgDark2], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                VStack {
                    StateButton(state: $centralManager.isScanning,
                                activeText: "Stop Scanning",
                                inactiveText: "Start Scanning",
                                action: updateScanState)
                    
                    DevicesList(btManager: centralManager,
                                _devices: $centralManager.devices,
                                searchText: $searchText)
                }
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
    
    @Binding var searchText: String
    
    var body: some View {
        ScrollView {
            ForEach(Array(_devices), id: \.self) { device in
                if !searchText.isEmpty {
                    let name = btManager.getPeripheralName(device).lowercased()
                    if name.contains(searchText.lowercased()) {
                        DeviceRow(btManager: btManager,
                                  device: device)
                    }
                }
                else {
                    DeviceRow(btManager: btManager,
                              device: device)
                }
            }
        }
        .padding()
        .searchable(text: $searchText, prompt: "Search by device name")
    }
}

struct DeviceRow: View {
    var btManager: CentralManager
    var device: CBPeripheral
    var maxStringLength: Int = 20
    
    var body: some View {
        NavigationLink(destination: PeripheralView(centralManager: btManager, peripheral: device)) {
            ZStack {
                Color(cgColor: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
                
                HStack {
                    Circle().foregroundColor(.random)
                        .frame(maxHeight: 30)
                    
                    Spacer()
                    
                    Text("\(truncatedName(btManager.getPeripheralName(device)))")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(btManager.translateRssiSimple(device.rssi?.intValue ?? 0))")
                }
                .padding()
            }
            .cornerRadius(15)
        }
    }
    
    func truncatedName(_ name: String) -> String {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
