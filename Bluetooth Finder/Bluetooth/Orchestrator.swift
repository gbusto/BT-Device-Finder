//
//  Orchestrator.swift
//  Bluetooth Finder
//
//  Created by Gabriel Busto on 1/12/23.
//

import Foundation
import Combine
import CoreBluetooth

class Orchestrator {
    static let shared = Orchestrator()
    
    var stopped: Bool = false
    
    func callStop() {
        CentralManager.shared.stop()
        stopped = true
    }
    
    func callResume() {
        CentralManager.shared.resume()
        stopped = false
    }
    
    func attemptReconnectDevice(device: CBPeripheral) {
        if !stopped {
            CentralManager.shared.connectToDevice(device)
        }
    }
    
    let stateSubscription = CentralManager.shared.statePublisher
        .sink { state in
            if state == CBManagerState.unauthorized {
                Orchestrator.shared.callStop()
            }
            else {
                if state == CBManagerState.poweredOn {
                    Orchestrator.shared.callResume()
                }
            }
        }
    
    let connectSubscription = CentralManager.shared.connectPublisher
        .sink { device in
            print("[+] Starting to monitor RSSI for device \(device.identifier)")
            CentralManager.shared.startMonitoringRssi(device)
        }
    
    let disconnectSubscription = CentralManager.shared.disconnectPublisher
        .sink { device in
            Orchestrator.shared.attemptReconnectDevice(device: device)
        }
}
