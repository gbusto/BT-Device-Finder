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
    
    @State public var deviceFavorited: Bool
    
    @State public var customDeviceName: String = ""

    @State private var showEditView: Bool = false
    
    @State private var showErrorAlert: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
        
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
                
                Image(rssiHelper
                        .getImageNameFor(getRssiForPeripheral(deviceId)))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250)
                                
                if centralManager.isConnectedToDevice(deviceId) {
                    Text("Successfully connected to device!")
                }
                else {
                    Text("Unable to connect to device")
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        updateFavorite()
                    } label: {
                        if deviceFavorited {
                            Label("", systemImage: "star.fill")
                        }
                        else {
                            Label("", systemImage: "star")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEditView = !showEditView
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                    .alert("Edit device name", isPresented: $showEditView, actions: {
                        TextField("Custom device name", text: $customDeviceName)
                        
                        Button("Save", action: updateName)
                        Button("Cancel", role: .cancel, action: {})
                    })
                }
            }
            // I'd like to fix this and remove the reliance on these attributes to show an error
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text(errorTitle),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")) {
                        resetError()
                      }
                )
            }
        }
        .onAppear {
            centralManager.requestFullDiscovery(forPeripheralWithId: deviceId)
        }
    }
    
    func updateName() {
        let result = PersistenceController.shared
            .updateObjectName(withId: deviceId,
                              withName: customDeviceName)
        
        switch result {
        case .success(_):
            // Pass; no nothing
            break
            
        case .failure(let error):
            print("Persistence error! \(error)")
            break
        }
    }
    
    func updateFavorite() {
        deviceFavorited = !deviceFavorited
        
        let result = PersistenceController.shared
            .updateObjectFavoriteStatus(withId: deviceId,
                                        withFavoriteStatus: deviceFavorited)
        
        switch result {
        case .success(_):
            // Pass; no nothing
            break
            
        case .failure(let error):
            errorTitle = "Error"
            errorMessage = "Error updating 'favorite' status for device. \(error)"
            showErrorAlert = true
            break
        }
    }
    
    func resetError() {
        showErrorAlert = false
        errorTitle = ""
        errorMessage = ""
    }
    
    func getRssiForPeripheral(_ deviceId: UUID) -> Int {
        if let rssi = centralManager.rssiReadings[deviceId] {
            return rssi
        }
        
        return 0
    }

}

struct PeripheralView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PeripheralView(deviceFavorited: false, deviceId: UUID(), deviceName: "Test Device")
                .environmentObject(CentralManager())
        }
    }
}
