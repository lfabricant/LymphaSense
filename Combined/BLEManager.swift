//
//  BLEManager.swift
//  AMAL
//
//  Created by Lindsay on 11/4/25.
//
import Foundation
import CoreBluetooth
import Combine
class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isScanning = false
    @Published var receivedText: String = ""
    @Published var connectedPeripheral: CBPeripheral?
    
    private var centralManager: CBCentralManager!
    private var uartServiceUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    private var txCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E") // from phone → Adafruit
    private var rxCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E") // from Adafruit → phone
    
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is ON — starting scan")
            startScan()
        } else {
            print("Bluetooth unavailable")
        }
    }
    
    func startScan() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: [uartServiceUUID], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown")")
        
        // Connect immediately for demo
        connectedPeripheral = peripheral
        centralManager.stopScan()
        isScanning = false
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([uartServiceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == uartServiceUUID {
            peripheral.discoverCharacteristics([txCharacteristicUUID, rxCharacteristicUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == txCharacteristicUUID {
                txCharacteristic = characteristic
            } else if characteristic.uuid == rxCharacteristicUUID {
                rxCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        print("UART characteristics ready")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.receivedText = text
            }
            print("Received: \(text)")
        }
    }
    
    // MARK: - Send Data
    func send(_ text: String) {
        guard let peripheral = connectedPeripheral, let tx = txCharacteristic else { return }
        if let data = text.data(using: .utf8) {
            peripheral.writeValue(data, for: tx, type: .withResponse)
        }
    }
}
