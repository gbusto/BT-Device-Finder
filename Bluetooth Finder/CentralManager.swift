//
//  CentralManager.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import Foundation
import CoreBluetooth

class CentralManager: NSObject, ObservableObject {
    
    public var centralManager: CBCentralManager!
    
    @Published public var devices: Set<CBPeripheral> = []
    
    @Published public var targetRssi: Int = .zero
    
    @Published public var isScanning: Bool = false
    
    private var stayConnected: Bool = false
        
    func start() {
        if centralManager == nil {
            centralManager = .init(CBCentralManager(delegate: self, queue: .main))
        }
    }
    
    private func translateState(_ btState: CBManagerState) -> String {
        switch btState {
        case .unknown:
            return "unknown"
        case .resetting:
            return "resetting"
        case .unsupported:
            return "unsupported"
        case .unauthorized:
            return "unauthorized"
        case .poweredOff:
            return "powered off"
        case .poweredOn:
            return "powered on"
        default:
            return "enexpected \(btState.rawValue)"
        }
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral)
        stayConnected = true
    }
    
    func disconnectFromDevice(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
        stayConnected = false
    }
    
    func readRssi(_ peripheral: CBPeripheral) {
        peripheral.readRSSI()
    }
    
    func getPeripheralName(_ peripheral: CBPeripheral) -> String {
        return peripheral.name ?? peripheral.identifier.uuidString
    }
    
    func startScanning() {
        if !isScanning {
            centralManager.scanForPeripherals(withServices: [])
            isScanning = true
            print("Started scanning for devices")
        }
        else {
            print("Already scanning for devices")
        }
    }
    
    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            print("Stopped scanning for devices")
        }
        else {
            print("Already stopped scanning for devices")
        }
    }
    
}

extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("[CBPeripheralDelegate] Read RSSI for peripheral \(getPeripheralName(peripheral)) - \(RSSI.intValue)")
        self.targetRssi = RSSI.intValue
    }
    
}

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[CBCentralManagerDelegate] CentralManager state updated to \(translateState(central.state))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[CBPeripheralDelegate] Successfully connected to peripheral \(getPeripheralName(peripheral))")
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("[CBCentralManagerDelegate] Discovered new peripheral: \(getPeripheralName(peripheral))")
        
        devices.insert(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("[CBCentralManagerDelegate] Disconnected from peripheral: \(getPeripheralName(peripheral))")
        
        if stayConnected {
            print("[CBCentralManagerDelegate] Attempting to re-connect to peripheral")
            connectToDevice(peripheral)
        }
    }
    
}
