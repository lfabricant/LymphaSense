//
//  NotificationManager.swift
//  AMAL
//
//  Created by Lindsay on 11/2/25. ChatGPT
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            } else {
                print("Permission granted: \(granted)")
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "AMAL"
        content.body = "Pressure out of range. Tap to view."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // open home page when click on notification (?)
}
