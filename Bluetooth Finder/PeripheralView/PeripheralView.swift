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
    
    @State public var customDeviceName: String = ""

    @State private var showEditView: Bool = false
    
    public var deviceId: UUID
    public var deviceName: String
        
    var rssiHelper: RssiHelper = RssiHelper()
                
    var body: some View {
        ZStack {
            BackgroundColor()
            
            VStack {
                Text("\(deviceName)")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                
                Spacer()
                
                RssiView(deviceId: deviceId,
                         rssiReadings: $centralManager.rssiReadings,
                         rssiHelper: rssiHelper)
                
                PeripheralConnectionView(isConnected: centralManager.isConnectedToDevice(deviceId))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button {
                        print("Edit")
                        showEditView = !showEditView
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                    .alert("Edit device name", isPresented: $showEditView, actions: {
                        TextField("Custom device name", text: $customDeviceName)
                        
                        Button("Save", action: saveName)
                        Button("Cancel", role: .cancel, action: {})
                    })
                }
            }
        }
        .onAppear {
            centralManager.requestFullDiscovery(forPeripheralWithId: deviceId)
        }
    }
    
    func saveName() {
        PersistenceController.shared.updateObjectWithId(deviceId, customDeviceName)
    }
}

struct EditView: View {
    @State var customName: String = ""
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            ScrollView {
                VStack {
                    TextField("Custom device name", text: $customName)
                        .font(.title)
                        .background(Color.gray)
                        .cornerRadius(5.0)
                        .shadow(radius: 5.0)
                }
                .padding()
            }
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

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PeripheralView(deviceId: UUID(), deviceName: "Test Device")
                .environmentObject(CentralManager())
        }
    }
}
