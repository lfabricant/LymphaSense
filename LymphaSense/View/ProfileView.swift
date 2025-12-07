//  ProfileView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI

struct ProfileView: View {
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
            
            Spacer()
            
            // 💡 Add the clear button here
            Button(role: .destructive) {
                // Display an alert for confirmation before clearing
                isShowingClearAlert = true
            } label: {
                Label("Clear All Data History", systemImage: "trash")
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            // Confirmation Alert
            .alert("Confirm Data Deletion", isPresented: $isShowingClearAlert) {
                Button("Delete", role: .destructive) {
                    bluetoothManager.clearHistory()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to permanently delete ALL recorded Bluetooth data? This cannot be undone.")
            }
        }
        .padding()
    }
    
    @State private var isShowingClearAlert = false // State for the confirmation alert
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
 

