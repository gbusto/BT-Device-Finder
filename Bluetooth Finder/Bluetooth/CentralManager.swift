//
//  CentralManager.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 12/24/22.
//

import Foundation
import CoreBluetooth

struct DeviceModel: Identifiable {
    var id: UUID { deviceId }
    var deviceId: UUID
    var deviceName: String
}

class CentralManager: NSObject, ObservableObject {
    
    public var centralManager: CBCentralManager!
    
    @Published public var devices: Set<CBPeripheral> = []
    @Published public var rssiReadings: [UUID: Int] = [:]
        
    @Published public var isScanning: Bool = false
    
    @Published public var isAuthorized: Bool = true
    
    private var stopped: Bool = false
        
    private var rssiTimers: [Timer] = []
        
    func create() {
        if centralManager == nil {
            centralManager = .init(CBCentralManager(delegate: self, queue: .main))
        }
    }
    
    func resume() {
        stopped = false
        
        self.startScanning()
    }
    
    func stop() {
        stopped = true

        self.stopScanning()
        
        for device in devices {
            centralManager.cancelPeripheralConnection(device)
        }

        for timer in rssiTimers {
            timer.invalidate()
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
    
    func getPeripheralById(_ deviceId: UUID) -> CBPeripheral? {
        if let p = devices.first(where: { $0.identifier == deviceId }) {
            return p
        }
        
        return nil
    }
    
    func getDevices() -> [DeviceModel] {
        var devList: [DeviceModel] = []
        
        for dev in devices {
            let d = DeviceModel(deviceId: dev.identifier,
                                deviceName: dev.name ?? "Unknown")
            devList.append(d)
        }
        
        return devList
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
    
    func isPoweredOn() -> Bool {
        return self.centralManager.state == CBManagerState.poweredOn
    }
    
    func startScanning() {
        if !isScanning && isPoweredOn() {
            // We may end up with duplicate devices if we don't reset these variables at the start of each scan
            devices = []
            
            centralManager.scanForPeripherals(withServices: [])
            isScanning = true
            Logger.print("[CentralManager] Started scanning for devices")
        }
        else {
            Logger.print("[CentralManager] Already scanning for devices")
        }
    }
    
    func stopScanning() {
        if isScanning {
            centralManager.stopScan()
            isScanning = false
            Logger.print("[CentralManager] Stopped scanning for devices")
        }
        else {
            Logger.print("[CentralManager] Already stopped scanning for devices")
        }
    }
    
    func startMonitoringRssi(_ peripheral: CBPeripheral) {
        let rssiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.readRssi(peripheral)
        }
        
        rssiTimers.append(rssiTimer)
    }
    
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
    
    func isConnectedToDevice(_ deviceId: UUID) -> Bool {
        if let peripheral = getPeripheralById(deviceId) {
            return peripheral.state == CBPeripheralState.connected
        }
        
        return false
    }
    
    func requestFullDiscovery(forPeripheralWithId deviceId: UUID) {
        if let peripheral = getPeripheralById(deviceId) {
            peripheral.discoverServices([])
        }
    }
}

extension CentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        Logger.print("[CBPeripheralDelegate] Read RSSI for peripheral \(getPeripheralName(peripheral)) - \(RSSI.intValue)")

        rssiReadings[peripheral.identifier] = RSSI.intValue
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Logger.print("[CBPeripheralDelegate] - TESTING - Did discover services for peripheral \(getPeripheralName(peripheral))")
        
        if let services = peripheral.services {
            for s in services {
                Logger.print("[CBPeripheralDelegate] - TESTING - SERVICE - \(s.uuid)")
                peripheral.discoverCharacteristics([], for: s)
            }
        }
        else {
            Logger.print("[CBPeripheralDelegate] - TESTING - [!] .services is empty for peripheral \(getPeripheralName(peripheral))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Logger.print("[CBPeripheralDelegate] - TESTING - Did discover characteristics for service \(service.uuid) on peripheral \(getPeripheralName(peripheral))")

        if let characteristics = service.characteristics {
            for ch in characteristics {
                Logger.print("[CBPeripheralDelegate] - TESTING - CHARACTERISTIC - \(ch.uuid), \(ch.value ?? "NIL".data(using: .utf8)!), \(ch.properties)")
                peripheral.discoverDescriptors(for: ch)
            }
        }
        else {
            Logger.print("[CBPeripheralDelegate] - TESTING - [!] .characteristics is empty for service \(service.uuid) on peripheral \(getPeripheralName(peripheral))")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        Logger.print("[CBPeripheralDelegate] - TESTING - Did discover descriptors for characteristic \(characteristic.uuid) on peripheral \(getPeripheralName(peripheral))")

        if let descriptors = characteristic.descriptors {
            for d in descriptors {
                Logger.print("[CBPeripheralDelegate] - TESTING - DESCRIPTOR - \(d.uuid), \(d.value ?? "NIL")")
            }
        }
        else {
            Logger.print("[CBPeripheralDelegate] - TESTING - [!] .descriptors is empty for characteristic \(characteristic.uuid) on peripheral \(getPeripheralName(peripheral))")
        }
    }
}

extension CentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Logger.print("[CBCentralManagerDelegate] CentralManager state updated to \(translateState(central.state))")
        
        if central.state == CBManagerState.unauthorized {
            self.isAuthorized = false
            
            self.stop()
        }
        else {
            if central.state == CBManagerState.poweredOn {
                self.resume()
            }

            self.isAuthorized = true
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Logger.print("[CBPeripheralDelegate] Successfully connected to peripheral \(getPeripheralName(peripheral))")
        peripheral.delegate = self

        self.startMonitoringRssi(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Logger.print("[CBPeripheralDelegate] Failed to connect to peripheral \(getPeripheralName(peripheral))")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        Logger.print("[CBCentralManagerDelegate] Discovered new peripheral: \(getPeripheralName(peripheral))")
        
        devices.insert(peripheral)
        centralManager.connect(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Logger.print("[CBCentralManagerDelegate] Disconnected from peripheral: \(getPeripheralName(peripheral))")
        
        if !stopped {
            Logger.print("[CBCentralManagerDelegate] Attempting to re-connect to peripheral")
            self.connectToDevice(peripheral)
        }
    }
    
}
