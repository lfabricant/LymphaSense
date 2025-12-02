//
//  AMALApp.swift
//  AMAL
//
//  Created by Lindsay on 10/27/25.
//

import SwiftUI


@main
struct AMALApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            //ContentView()
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
