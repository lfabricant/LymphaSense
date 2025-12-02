//
//  BluetoothManager.swift
//  AMAL
//
//  Created by Lindsay on 11/2/25. ChatGPT
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var connectedPeripheral: CBPeripheral?
    @Published var receivedText: String = "Waiting for data..."

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Called whenever Bluetooth state changes
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("✅ Bluetooth is ON, starting scan")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .resetting, .unauthorized, .unsupported, .poweredOff:
            print("⚠️ Bluetooth not ready: \(central.state.rawValue)")
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
            print("📡 Found device: \(peripheral.name ?? "Unnamed")")
        }
    }
}
