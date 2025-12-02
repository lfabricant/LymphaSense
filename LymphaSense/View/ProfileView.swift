//
//  ProfileView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

/*

import SwiftUI

struct ProfileView: View {
    
    // 🎯 FIX: Use @EnvironmentObject to access the shared manager instance
    // created in ContentView, rather than creating a new one with @StateObject.
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack(spacing: 20) {
            
            Text("User Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // --- Section: Bluetooth Management ---
            
            Text("Device Connection")
                .font(.title2)
                .foregroundColor(.gray)
            
            // NavigationLink styled to look like a prominent button
            NavigationLink(destination: BluetoothView(bluetoothManager: bluetoothManager)) {
                Text("Connect or Reconnect Device")
            }
            .buttonStyle(.plain)
            
            Text(bluetoothManager.isConnected ? "Status: Currently Connected" : "Status: Disconnected")
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                .font(.headline)
            
            Divider()
            
            // --- Section: Push Notifications Demo ---
            
            Text("Notifications Demo")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button("Send Local Notification") {
                print("Button tapped ✅")
                // NOTE: Using the generic scheduleLocalNotification.
                // You may want to update NotificationManager to include a generic test notification.
                NotificationManager.shared.scheduleLocalNotification()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)

            Spacer()
        }
    }
}

// Ensure the Preview also provides the Environment Object
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // You must provide a dummy BluetoothManager for the preview to work
        ProfileView()
            .environmentObject(BluetoothManager())
    }
}
 
 */

//  ProfileView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI

struct ProfileView: View {
    //@StateObject private var bluetoothManager = BluetoothManager()
    @EnvironmentObject var bluetoothManager: BluetoothManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // MARK: - Bluetooth
            Text("Profile")
                    .font(.title)
                
            NavigationLink(destination: BluetoothView(bluetoothManager: bluetoothManager)) {
                Text("Connect to Device")
            }
            .buttonStyle(.borderedProminent)
            
            Text(bluetoothManager.isConnected ? "Status: Currently Connected" : "Status: Disconnected")
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
                .font(.headline)
            
                
            // MARK: - Push Notifications
            Text("Push Notification Demo")
                .font(.title)
            
            Button("Send Local Notification") {
                print("Button tapped ✅")
                NotificationManager.shared.scheduleLocalNotification()
            }
            .buttonStyle(.borderedProminent)
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
 

