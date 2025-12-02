//
//  BluetoothView.swift
//  LymphaSense
//
//  Created by Lindsay on 11/28/25.
//

import SwiftUI
import CoreBluetooth
import Combine

struct BluetoothView: View {
    
    // 💡 Note: This assumes the BluetoothManager is created higher up (e.g., in the App file)
    @ObservedObject var bluetoothManager: BluetoothManager
    
    // An optional state to hold the current status (e.g., for display)
    @State private var bluetoothStatusMessage: String = "Initializing Bluetooth..."
    
    var body: some View {
        VStack {
            Text("Connect to Device")
                .font(.largeTitle)
                .padding(.bottom)

            // Display current Bluetooth status
            Text(bluetoothStatusMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            if bluetoothManager.isScanning {
                ProgressView("Scanning…")
                    .padding()
            }

            // --- List of Discovered Peripherals ---
            List(bluetoothManager.peripherals, id: \.identifier) { peripheral in
                Button(action: {
                    // Check if the peripheral is non-nil before connecting (safety check)
                    guard peripheral.state == .disconnected else {
                        print("Peripheral already connecting or connected.")
                        return
                    }
                    bluetoothManager.connect(peripheral)
                }) {
                    VStack(alignment: .leading) {
                        Text(peripheral.name ?? "Unknown Device")
                            .font(.headline)
                        // Display identifier for debugging
                        Text(peripheral.identifier.uuidString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .listStyle(.plain)
            
            Spacer()

            // --- Manual Scan Button ---
            Button("Scan for Devices") {
                // This will safely call startScan, which has a guard to check state == .poweredOn
                bluetoothManager.startScan()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .disabled(bluetoothManager.isScanning) // Disable button while scanning
        }
        // Use onAppear to perform setup if needed, but DO NOT call scan here.
        .onAppear {
            // Setup observers for better status reporting
            updateStatusMessage(for: bluetoothManager.central.state)
        }
        // Use an observer to update the status text whenever the central's state changes
        .onReceive(bluetoothManager.objectWillChange) {
            // Since we don't have direct access to central.state via @Published,
            // we'll rely on the change being reported and update the status here.
            updateStatusMessage(for: bluetoothManager.central.state)
        }
    }
    
    // Helper function to map CBManagerState to a user-friendly string
    private func updateStatusMessage(for state: CBManagerState) {
        switch state {
        case .poweredOn:
            bluetoothStatusMessage = bluetoothManager.isScanning ? "Bluetooth ON. Scanning..." : "Bluetooth ON. Ready to Scan."
        case .unknown:
            bluetoothStatusMessage = "Bluetooth Initializing (Unknown)."
        case .poweredOff:
            bluetoothStatusMessage = "Bluetooth OFF. Please turn on Bluetooth."
        case .unauthorized:
            bluetoothStatusMessage = "App is Unauthorized to use Bluetooth."
        case .unsupported:
            bluetoothStatusMessage = "Device does not support Bluetooth LE."
        case .resetting:
            bluetoothStatusMessage = "Bluetooth connection lost. Resetting..."
        @unknown default:
            bluetoothStatusMessage = "Bluetooth Status Error."
        }
    }
}

// ⚠️ REQUIRED: You must ensure your App struct or a parent view creates and provides the manager:
/*
struct ContentView: View {
    @StateObject var btManager = BluetoothManager() // Creates the manager instance

    var body: some View {
        BluetoothView(bluetoothManager: btManager) // Passes the instance
    }
}
*/
