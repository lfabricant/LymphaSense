//
//  ProfileView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI
struct ProfileView: View {
    @StateObject var bleManager = BLEManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            
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
