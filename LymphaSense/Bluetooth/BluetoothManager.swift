//

//  BluetoothManager.swift

//  LymphaSense

//

//  Created by Lindsay on 11/28/25.

//

// Add this struct outside the BluetoothManager class, maybe at the top of the file.
struct BluetoothDataPoint: Identifiable {
    let id = UUID() // Useful for ForEach in SwiftUI
    let timestamp: Date
    let value: String
    
    
}


import Foundation

import CoreBluetooth

import Combine



// --- Bluetooth Manager Implementation ---



protocol BluetoothManagerDelegate: AnyObject {

    func didUpdatePeripherals(_ peripherals: [CBPeripheral])

    func didConnect(_ peripheral: CBPeripheral)

    func didFail(error: Error?)

}



//class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @Published var isScanning: Bool = false

    @Published private(set) var peripherals: [CBPeripheral] = []

    private var rssiArray = [NSNumber]()

    @Published var isConnected: Bool = false
    
    //@Published var receivedDataHistory: [String] = []
    @Published var receivedDataHistory: [BluetoothDataPoint] = []



    weak var delegate: BluetoothManagerDelegate?



    var central: CBCentralManager!

    private var targetPeripheral: CBPeripheral?

    private var txCharacteristic: CBCharacteristic!

    private var rxCharacteristic: CBCharacteristic!



    /*override init() {

        super.init()

        // Initialization immediately starts the state checks

        central = CBCentralManager(delegate: self, queue: .main)

    }*/
    
    override init() {
        super.init()
        
        // ⭐️ Crucial Update: Add the restoration identifier and the right options
        let options: [String: Any] = [
            CBCentralManagerOptionRestoreIdentifierKey: "LymphaSense.centralmanager", // 👈 Use a unique string
            CBCentralManagerOptionShowPowerAlertKey: true
        ]
        
        // Use the options when initializing the central manager
        central = CBCentralManager(delegate: self, queue: .main, options: options)
    }



    // --- MARK: - 🔋 State (THE CRITICAL FIX LOCATION)

    

    // The centralManagerDidUpdateState is the *only* correct place to begin the scan.

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {

        case .poweredOn:

            print("Bluetooth is powered on. Starting scan now...")

            // ✅ FIX: The scan is triggered ONLY when the state is ready.

            startScan()

        case .unknown:

            print("Bluetooth state is unknown (0). Waiting for update...")

        case .poweredOff:

            print("Bluetooth is powered off (4). Please turn on Bluetooth.")

            isScanning = false

        case .resetting:

            print("Bluetooth connection is temporarily lost (1).")

            isScanning = false

        case .unsupported:

            print("Bluetooth Low Energy is not supported (3).")

            isScanning = false

        case .unauthorized:

            print("The app is not authorized to use Bluetooth (2).")

            isScanning = false

        @unknown default:

            print("A new state was added that is not yet handled.")

            isScanning = false

        }

    }



    // --- MARK: - 🔍 Scan (Targeted Service)

    

    // Scan function with an added state check for robustness.

    func startScan() {

        guard central.state == .poweredOn else {

            print("Cannot start scan, Bluetooth is not powered on. Current state: \(central.state.rawValue)")

            return

        }



        peripherals.removeAll()

        isScanning = true



        print("Scanning for Bluefruit UART…")

        central.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])



        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in

            self?.stopScan()

        }

    }

    

    // --- MARK: - 🔍 Scan (General BLE)

    

    // General scan function with an added state check for robustness.

    func scanForBLEDevices() {

        guard central.state == .poweredOn else {

            print("Cannot start general scan, Bluetooth is not powered on. Current state: \(central.state.rawValue)")

            return

        }

        

        peripherals.removeAll()

        rssiArray.removeAll()

            

        central.scanForPeripherals(withServices: [] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])

        print("Scanning for all BLE Devices…")



        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in

            self?.stopScan()

        }

    }



    func stopScan() {

        central?.stopScan()

        isScanning = false

        print("Stopped scanning.")

        delegate?.didUpdatePeripherals(peripherals)

    }



    // --- MARK: - 📡 Discovery

    

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("Function: \(#function),Line: \(#line)")



        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {

            peripherals.append(peripheral)

            rssiArray.append(RSSI)

            delegate?.didUpdatePeripherals(peripherals)

        }

        

        print("Peripheral Discovered: \(peripheral.name ?? "Unknown")")

    }



    // Convenience to match SwiftUI view call site

    func connect(_ peripheral: CBPeripheral) {

        connect(to: peripheral)

    }



    // --- MARK: - 🔗 Connect

    

    func connect(to peripheral: CBPeripheral) {

        targetPeripheral = peripheral

        targetPeripheral?.delegate = self

        central.connect(peripheral, options: nil)

        stopScan()

    }



    func centralManager(_ central: CBCentralManager,

                        didConnect peripheral: CBPeripheral) {

        print("Connected:", peripheral.name ?? "Unknown")

        delegate?.didConnect(peripheral)

        isConnected = true

        peripheral.discoverServices([CBUUIDs.BLEService_UUID])

    }

    

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {

        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")

        delegate?.didFail(error: error)

        targetPeripheral = nil

    }



    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        print("Disconnected from \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")

        isConnected = false

        

        // 🎯 Action: Send the disconnection notification

        NotificationManager.shared.scheduleDisconnectionNotification(deviceName: peripheral.name)

        

        targetPeripheral = nil

        self.isConnected = false

    }



    // --- MARK: - ⚙️ Services → Characteristics

    

    func peripheral(_ peripheral: CBPeripheral,

                    didDiscoverServices error: Error?) {



        if let error = error {

            delegate?.didFail(error: error)

            return

        }



        peripheral.services?.forEach {

            peripheral.discoverCharacteristics(nil, for: $0)

        }

    }

    

    // --- MARK: - Added Functionality

    

    func connectToDevice() -> Void {

        guard let peripheral = targetPeripheral else { return }

        central?.connect(peripheral, options: nil)

    }

    

    func disconnectFromDevice() -> Void {

        if let peripheral = targetPeripheral {

            central?.cancelPeripheralConnection(peripheral)

        }

    }

    

    func removeArrayData() -> Void {

        if let peripheral = targetPeripheral {

            central.cancelPeripheralConnection(peripheral)

        }

        rssiArray.removeAll()

        peripherals.removeAll()

    }

    

    func delayedConnection() -> Void {

        BlePeripheral.connectedPeripheral = targetPeripheral

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {

            print("Delayed connection.")

        })

    }

    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {



        guard let characteristics = service.characteristics else {

            return

        }



        print("Found \(characteristics.count) characteristics.")



        for characteristic in characteristics {



            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

                rxCharacteristic = characteristic

                BlePeripheral.connectedRXChar = rxCharacteristic

                peripheral.setNotifyValue(true, for: rxCharacteristic)

                peripheral.readValue(for: characteristic)

                print("RX Characteristic: \(rxCharacteristic.uuid)")

            }



            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){

                txCharacteristic = characteristic

                BlePeripheral.connectedTXChar = txCharacteristic

                print("TX Characteristic: \(txCharacteristic.uuid)")

            }

        }

        delayedConnection()

    }



    // --- MARK: - 📩 Data Handling
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

            guard characteristic == rxCharacteristic,
                  let characteristicValue = characteristic.value,
                  let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue)
            else {
                return
            }

            let receivedString = ASCIIstring as String

            print("Value Recieved: \(receivedString)")
            
            // 🎯 FIX: Append the received string to the published array
            DispatchQueue.main.async {
                //self.receivedDataHistory.append(receivedString)
                let newPoint = BluetoothDataPoint(timestamp: Date(), value: receivedString)
                        self.receivedDataHistory.append(newPoint)
            }

            // Keep the NotificationCenter post for legacy/testing purposes
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: receivedString)
        }

    

    /*func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {



        var characteristicASCIIValue = NSString()



        guard characteristic == rxCharacteristic,



              let characteristicValue = characteristic.value,

              let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }


        characteristicASCIIValue = ASCIIstring


        print("Value Recieved: \((characteristicASCIIValue as String))")
    

        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: "\((characteristicASCIIValue as String))")

    } */



    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {

        peripheral.readRSSI()

    }



    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

        guard error == nil else {

            print("Error writing value: \(error!.localizedDescription)")

            return

        }

        print("Function: \(#function),Line: \(#line)")

        print("Message sent")

    }





    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {

        print("*******************************************************")

        print("Function: \(#function),Line: \(#line)")

        if (error != nil) {

            print("Error changing notification state:\(String(describing: error?.localizedDescription))")



        } else {

            print("Characteristic's value subscribed")

        }



        if (characteristic.isNotifying) {

            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")

        }

    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // ⭐️ This is where the system passes back the peripheral it was monitoring.
        if let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                // Re-assign the delegate so your manager can receive the disconnection event
                peripheral.delegate = self
                
                // Set your internal state properties if needed
                self.targetPeripheral = peripheral
                self.isConnected = (peripheral.state == .connected)
            }
        }
    }



}

// BluetoothManager.swift

extension BluetoothManager {
    
    /*func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("Restoring Bluetooth Manager State...")

        // 1. Restore Peripherals
        if let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            // Reassign the restored peripherals to your array
            self.peripherals = peripherals
            
            // Reconnect to any restored peripherals that were connected or connecting
            for peripheral in peripherals {
                // You may want to check if the peripheral was connected before reconnecting
                // and assign the delegate again
                peripheral.delegate = self
                
                // You may need to manually re-connect them if they were only 'connecting' or
                // if they are now disconnected and you want the connection to be maintained.
                if peripheral.state == .connecting || peripheral.state == .connected {
                    self.targetPeripheral = peripheral
                    self.isConnected = (peripheral.state == .connected)
                    print("Restored peripheral: \(peripheral.name ?? "Unknown")")
                }
            }
        }

        // 2. Restore Scan Options (if needed)
        if dict[CBCentralManagerRestoredStateScanServicesKey] != nil {
             print("Restored scan in progress.")
             // If a scan was active, you don't need to manually restart it.
        }
    }*/
}

/*
 //
 //  BluetoothManager.swift
 //  LymphaSense
 //
 //  Created by Lindsay on 11/28/25.
 //

 import Foundation
 import CoreBluetooth
 import Combine

 // Assuming CBUUIDs and BlePeripheral definitions are elsewhere or provided in the full context

 // --- Bluetooth Manager Implementation ---

 protocol BluetoothManagerDelegate: AnyObject {
     func didUpdatePeripherals(_ peripherals: [CBPeripheral])
     func didConnect(_ peripheral: CBPeripheral)
     func didFail(error: Error?)
 }

 class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {

     // MARK: - Published Properties for SwiftUI View State
     @Published var isScanning: Bool = false
     @Published private(set) var peripherals: [CBPeripheral] = []
     @Published var isConnected: Bool = false
     
     // 🎯 NEW: Published array to store all received data strings
     @Published var receivedDataHistory: [String] = []

     // MARK: - Private/Internal Properties
     private var rssiArray = [NSNumber]()
     weak var delegate: BluetoothManagerDelegate?

     var central: CBCentralManager!
     private var targetPeripheral: CBPeripheral?
     private var txCharacteristic: CBCharacteristic!
     private var rxCharacteristic: CBCharacteristic!

     override init() {
         super.init()
         central = CBCentralManager(delegate: self, queue: .main)
     }

     // --- MARK: - 🔋 State (Initial Scan Trigger)
     func centralManagerDidUpdateState(_ central: CBCentralManager) {
         switch central.state {
         case .poweredOn:
             print("Bluetooth is powered on. Starting scan now...")
             startScan()
         case .unknown:
             print("Bluetooth state is unknown (0). Waiting for update...")
         case .poweredOff:
             print("Bluetooth is powered off (4). Please turn on Bluetooth.")
             isScanning = false
         case .resetting:
             print("Bluetooth connection is temporarily lost (1).")
             isScanning = false
         case .unsupported:
             print("Bluetooth Low Energy is not supported (3).")
             isScanning = false
         case .unauthorized:
             print("The app is not authorized to use Bluetooth (2).")
             isScanning = false
         @unknown default:
             print("A new state was added that is not yet handled.")
             isScanning = false
         }
     }

     // --- MARK: - 🔍 Scan (Targeted Service)
     func startScan() {
         guard central.state == .poweredOn else {
             print("Cannot start scan, Bluetooth is not powered on. Current state: \(central.state.rawValue)")
             return
         }

         peripherals.removeAll()
         isScanning = true

         print("Scanning for Bluefruit UART…")
         // Assuming CBUUIDs.BLEService_UUID is defined
         // central.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])

         DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
             self?.stopScan()
         }
     }
     
     // --- MARK: - 🔍 Scan (General BLE)
     func scanForBLEDevices() {
         guard central.state == .poweredOn else {
             print("Cannot start general scan, Bluetooth is not powered on. Current state: \(central.state.rawValue)")
             return
         }
             
         peripherals.removeAll()
         rssiArray.removeAll()
             
         central.scanForPeripherals(withServices: [] , options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
         print("Scanning for all BLE Devices…")

         DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
             self?.stopScan()
         }
     }

     func stopScan() {
         central?.stopScan()
         isScanning = false
         print("Stopped scanning.")
         delegate?.didUpdatePeripherals(peripherals)
     }

     // --- MARK: - 📡 Discovery/Connect/Disconnect (Omitted for brevity, assumed functional)
     
     func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
         // ... (Discovery logic) ...
     }
     
     func connect(_ peripheral: CBPeripheral) {
         // ... (Connection logic) ...
     }

     func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
         print("Connected:", peripheral.name ?? "Unknown")
         delegate?.didConnect(peripheral)
         isConnected = true
         // peripheral.discoverServices([CBUUIDs.BLEService_UUID])
     }
     
     func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
         // ... (Fail to Connect logic) ...
     }

     func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
         print("Disconnected from \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "Unknown error")")
         isConnected = false
         
         // 🎯 Action: Send the disconnection notification
         // Assuming NotificationManager is defined
         // NotificationManager.shared.scheduleDisconnectionNotification(deviceName: peripheral.name)
         
         targetPeripheral = nil
         self.isConnected = false
     }

     // --- MARK: - ⚙️ Services → Characteristics (Omitted for brevity, assumed functional)
     // ...

     // --- MARK: - 📩 Data Handling (FIXED HERE)
     
     func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

         guard characteristic == rxCharacteristic,
               let characteristicValue = characteristic.value,
               let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue)
         else {
             return
         }

         let receivedString = ASCIIstring as String

         print("Value Recieved: \(receivedString)")
         
         // 🎯 FIX: Append the received string to the published array
         // Use DispatchQueue.main.async since this delegate method might not be on the main thread,
         // and updating a @Published property must happen on the main thread.
         DispatchQueue.main.async {
             self.receivedDataHistory.append(receivedString)
         }

         // NotificationCenter post kept for compatibility but should be replaced by @Published
         NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: receivedString)
     }

     // --- MARK: - Other Peripheral Methods (Omitted for brevity, assumed functional)
     // ...
 }
 */
