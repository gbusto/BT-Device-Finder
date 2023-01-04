//
//  ContentView.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import SwiftUI
import CoreData
import CoreBluetooth

struct PrimaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var centralManager: CentralManager = CentralManager()
        
    @State var searchText: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                VStack {
                    StateButton(state: $centralManager.isScanning,
                                activeText: "Stop Scanning",
                                inactiveText: "Start Scanning",
                                action: updateScanState)
                    
                    DevicesList(devices: $centralManager.devices,
                                rssiReadings: $centralManager.rssiReadings,
                                searchText: $searchText)
                        .environmentObject(centralManager)
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
    @EnvironmentObject var btManager: CentralManager
    
    @Binding var devices: Set<CBPeripheral>
    @Binding var rssiReadings: [UUID: Int]
    
    @FetchRequest(sortDescriptors: []) var savedDevices: FetchedResults<Device>
    
    @Binding var searchText: String
    
    var body: some View {
        ScrollView {
            ForEach(Array(devices) as [CBPeripheral], id: \.self) { device in
                let deviceId = device.identifier
                let deviceName = getDeviceName(device)
                
                let deviceRow = DeviceRow(deviceId: deviceId,
                                          deviceName: deviceName,
                                          rssi: getRssiForPeripheral(deviceId))
                if !searchText.isEmpty {
                    if deviceName.lowercased().contains(searchText.lowercased()) {
                        deviceRow
                    }
                }
                else {
                    deviceRow
                }
            }
        }
        .padding()
        .searchable(text: $searchText, prompt: "Search by device name")
    }
    
    func getRssiForPeripheral(_ deviceId: UUID) -> Int {
        if let rssi = rssiReadings[deviceId] {
            return rssi
        }
        
        return 0
    }
    
    func getDeviceName(_ device: CBPeripheral) -> String {
        var deviceName: String = device.name ?? "Unknown"
        
        if let item = savedDevices.first(where: { $0.id == device.identifier }) {
            if let cn = item.customName {
                if !cn.isEmpty {
                    deviceName = cn
                }
            }
        }

        return deviceName
    }
    
    func checkIfDeviceWasSaved(_ deviceId: UUID) {
        if let item = PersistenceController.shared.getObjectWithId(deviceId) {
            debugPrint("Got item! Custom name is \(String(describing: item.value(forKey: "customName") as? String))")
        }
        else {
            print("No item found for ID \(deviceId.uuidString)")
        }
    }

}

struct DeviceRow: View {
    @EnvironmentObject var btManager: CentralManager

    var deviceId: UUID
    var deviceName: String
    var rssi: Int
    var maxStringLength: Int = 20
    
    var body: some View {
        NavigationLink(destination: PeripheralView(customDeviceName: deviceName,
                                                   deviceId: deviceId,
                                                   deviceName: deviceName)
                .environmentObject(btManager)) {
            ZStack {
                Color(cgColor: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1))
                
                HStack {
                    Circle().foregroundColor(.random)
                        .frame(maxWidth: 30)
                    
                    Spacer()
                    
                    Text("\(truncatedName(deviceName))")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image("\(btManager.translateRssiSimple(rssi))")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30)
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

struct PrimaryView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryView()
    }
}
