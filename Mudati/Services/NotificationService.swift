//
//  NotificationService.swift
//  Mudati
//
//  Created by Alanoud Aljasser on 14/12/1447 AH.
//

import Foundation
import UserNotifications

final class NotificationService {
    
    static let shared = NotificationService()
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification permission error:", error.localizedDescription)
            }
            print("Notifications granted:", granted)
        }
    }

    func scheduleRenewalReminders(for subscription: Subscription) {
        cancelReminders(for: subscription)
        
        guard !subscription.isArchived else { return }
        guard !subscription.isExpired else { return }
        
        let reminderDays = [7, 3, 1]
        
        for day in reminderDays {
            guard let reminderDate = Calendar.current.date(
                byAdding: .day,
                value: -day,
                to: subscription.endDate
            ) else { continue }
            
            guard reminderDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = notificationTitle(for: subscription, day: day)
            content.body = notificationBody(for: subscription, day: day)
            content.sound = .default
            
            var triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day],
                from: reminderDate
            )

            triggerDate.hour = 9
            triggerDate.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: triggerDate,
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "\(subscription.name)-\(day)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("Schedule notification error:", error.localizedDescription)
                }
            }
        }
    }
    
    func cancelReminders(for subscription: Subscription) {
        let ids = [7, 3, 1].map { "\(subscription.name)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    private func notificationTitle(for subscription: Subscription, day: Int) -> String {
        if subscription.autoRenew {
            return "💳 سحب تلقائي قريب"
        }
        
        if day == 1 {
            return "⏳ الاشتراك ينتهي غدًا"
        }
        
        return "⏳ اشتراكك قرب ينتهي"
    }
    
    private func notificationBody(for subscription: Subscription, day: Int) -> String {
        if subscription.autoRenew && !subscription.willRenew {
            return "\(subscription.name) فيه سحب تلقائي بعد \(day) يوم، والاستمرار غير مؤكد."
        }
        
        if subscription.autoRenew {
            return "\(subscription.name) سيتم سحبه تلقائيًا بعد \(day) يوم."
        }
        
        if subscription.willRenew {
            return "\(subscription.name) ينتهي بعد \(day) يوم، وأنت محدد أنك مستمر فيه."
        }
        
        return "\(subscription.name) ينتهي بعد \(day) يوم."
    }
}
