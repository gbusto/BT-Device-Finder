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
    @Published public var rssiReadings: [UUID: Int] = [:]
        
    @Published public var isScanning: Bool = false
        
    private var rssiTimers: [Timer] = []
        
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
    }
    
    func disconnectFromDevice(_ peripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(peripheral)
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
            print("[CentralManager] Started scanning for devices")
        }
        else {
            print("[CentralManager] Already scanning for devices")
        }
    }
    
    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            print("[CentralManager] Stopped scanning for devices")
        }
        else {
            print("[CentralManager] Already stopped scanning for devices")
        }
    }
    
    func startMonitoringRssi(_ peripheral: CBPeripheral) {
        let rssiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.readRssi(peripheral)
        }
        
        rssiTimers.append(rssiTimer)
    }
    
    // Figure out when to use this function, or get rid of it altogether
    /*
    func stopMonitoringRssi() {
        if let timer = rssiTimer {
            if timer.isValid {
                timer.invalidate()
                print("[CentralManager] Canceled timer")
            }
            else {
                print("[CentralManager] Timer has already been canceled")
            }
        }
        else {
            print("[CentralManager] No timer found")
        }
    }
    */
    
    func translateRssiSimple(_ rssi: Int) -> String {
        if rssi >= -90 && rssi < -80 {
            return "red-signal-simple"
        }
        
        if rssi >= -80 && rssi < -65 {
            return "orange-signal-simple"
        }
        
        if rssi >= -65 && rssi < -45 {
            return "yellow-signal-simple"
        }
        
        if rssi >= -45 && rssi <= -30 {
            return "green-signal-simple"
        }
        
        return "no-signal-simple"
    }
    
    func isConnectedToDevice(_ peripheral: CBPeripheral) -> Bool {
        return peripheral.state == CBPeripheralState.connected
    }
}

extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("[CBPeripheralDelegate] Read RSSI for peripheral \(getPeripheralName(peripheral)) - \(RSSI.intValue)")

        rssiReadings[peripheral.identifier] = RSSI.intValue
    }
}

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[CBCentralManagerDelegate] CentralManager state updated to \(translateState(central.state))")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[CBPeripheralDelegate] Successfully connected to peripheral \(getPeripheralName(peripheral))")
        peripheral.delegate = self

        self.startMonitoringRssi(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[CBPeripheralDelegate] Failed to connect to peripheral \(getPeripheralName(peripheral))")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("[CBCentralManagerDelegate] Discovered new peripheral: \(getPeripheralName(peripheral))")
        
        devices.insert(peripheral)
        centralManager.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("[CBCentralManagerDelegate] Disconnected from peripheral: \(getPeripheralName(peripheral))")
        
        print("[CBCentralManagerDelegate] Attempting to re-connect to peripheral")
        self.connectToDevice(peripheral)
    }
    
}
