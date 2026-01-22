import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            return granted
        } catch {
            print("Notification authorization failed: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Daily Reminder
    func scheduleDailyReminder(at time: Date) {
        // Cancel existing reminders
        cancelDailyReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Pray"
        content.body = "Take a moment to connect with God today. Your peace awaits."
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_prayer_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error)")
            }
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_prayer_reminder"]
        )
    }
    
    // MARK: - Streak Reminder
    func scheduleStreakReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You haven't prayed today. Keep your streak going!"
        content.sound = .default
        
        // Schedule for 8 PM if user hasn't prayed today
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "streak_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelStreakReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["streak_reminder"]
        )
    }
    
    // MARK: - Unlock Expiring
    func scheduleUnlockExpiringNotification(in minutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Apps Locking Soon"
        content.body = "Your unlock window is about to expire in 1 minute."
        content.sound = .default
        
        // Notify 1 minute before expiry
        let warningTime = TimeInterval((minutes - 1) * 60)
        guard warningTime > 0 else { return }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: warningTime, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "unlock_expiring",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelUnlockExpiringNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["unlock_expiring"]
        )
    }
}

// MARK: - Notification Categories
extension NotificationManager {
    func registerCategories() {
        let prayNowAction = UNNotificationAction(
            identifier: "PRAY_NOW",
            title: "Pray Now",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Later",
            options: []
        )
        
        let dailyCategory = UNNotificationCategory(
            identifier: "DAILY_REMINDER",
            actions: [prayNowAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([dailyCategory])
    }
}
