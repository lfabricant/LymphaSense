//
//  ContentView.swift
//  AMAL
//
//  Created by Lindsay on 10/27/25.
//
//
//  ContentView.swift
//  AMAL
//
//  Created by Lindsay on 10/27/25.
//

import SwiftUI

struct ContentView: View {
    // 1. Bluetooth Manager is the source of truth for the connection state.
    // Ensure this is the highest level where the manager is instantiated.
    @StateObject var bluetoothManager = BluetoothManager()

    // 2. Local state derived from the manager's published property.
    @State private var isAuthenticatedAndConnected: Bool = false

    var body: some View {
        // The NavigationStack is the root container for navigation context.
        NavigationStack {
            
            // 3. Conditional logic to switch the root view based on connection status.
            if isAuthenticatedAndConnected {
                // Device connected: Show the main application views (TabView starting with HomeView).
                MainTabView()
                    .environmentObject(bluetoothManager) // Pass the manager down
            } else {
                // Device disconnected: Show the connection/setup view.
                // This is where the user interacts to connect the device.
                BluetoothView(bluetoothManager: bluetoothManager) // Pass the manager explicitly
            }
        }
        .environmentObject(bluetoothManager)
        
        // 4. Observe the manager's connection status.
        .onReceive(bluetoothManager.$isConnected) { isConnected in
            // Update the local state, which causes the body to redraw and switch views.
            isAuthenticatedAndConnected = isConnected
            
            if isConnected {
                print("✅ Device Connected. Root view switched to MainTabView/HomeView.")
            } else {
                print("❌ Device Disconnected. Root view switched to BluetoothView.")
            }
        }
    }
}
