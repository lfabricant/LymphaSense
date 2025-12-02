//
//  NotificationManager.swift
//  AMAL
//
//  Created by Lindsay on 11/2/25.
//

import Foundation
import UserNotifications
import UIKit

// ⭐️ Conform to UNUserNotificationCenterDelegate
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        // ⭐️ Set the delegate in the initializer
        UNUserNotificationCenter.current().delegate = self
    }
    
    // ... (Your existing functions: requestAuthorization, scheduleLocalNotification, etc.)
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // ⭐️ This is the crucial method: It ensures the notification shows up
    // even when the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification received in foreground.")
        
        // This tells the system to display the notification as an alert, with sound, and badge.
        completionHandler([.banner, .sound, .badge])
    }

    // You can also implement this if you want to handle the user tapping the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("User tapped the notification.")
        // Handle deep-linking or navigation here if needed
        
        completionHandler()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            } else {
                print("Permission granted: \(granted)")
            }
            
            DispatchQueue.main.async {
                // Registering for remote notifications is usually only needed for push notifications (APNs).
                // For local notifications, this line is often unnecessary, but kept here for completeness if you use APNs later.
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // MARK: - Local Notification Test
    func scheduleLocalNotification() {
        print("Sending local notification.")
        let content = UNMutableNotificationContent()
        content.title = "LymphaSense"
        content.body = "Test notification. Tap to view."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification for Bluetooth Disconnection (New)
    func scheduleDisconnectionNotification(deviceName: String?) {
        print("Sending disconnected notification.")
        let name = deviceName ?? "device"
        let content = UNMutableNotificationContent()
        content.title = "LymphaSense"
        content.body = "Bluetooth connection lost. Please reconnect \(name) to continue monitoring."
        content.sound = .default
        
        // Use a unique ID to allow multiple disconnections to be notified
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling disconnection notification: \(error.localizedDescription)")
            }
        }
    }
    
    // open home page when click on notification (?)
    // This requires implementing the UNUserNotificationCenterDelegate protocol
    // in your AppDelegate or SceneDelegate and handling the delegate method:
    // userNotificationCenter(_:didReceive:withCompletionHandler:)
}
