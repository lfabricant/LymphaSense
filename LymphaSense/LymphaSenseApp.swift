//
//  LymphaSenseApp.swift
//  LymphaSense
//
//  Created by Lindsay on 10/27/25.
//


import SwiftUI

@main
struct LymphaSenseApp: App {
    init() {
            // Must request permission here!
            NotificationManager.shared.requestAuthorization()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                //.onAppear {
                   // NotificationManager.shared.requestAuthorization()
               // }
        }
    }
}
