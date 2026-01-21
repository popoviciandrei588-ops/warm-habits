import Foundation
import SwiftData

/// User settings model for storing app preferences
@Model
final class UserSettings {
    /// Unique identifier
    var id: UUID
    
    /// Whether the user has completed onboarding
    var hasCompletedOnboarding: Bool
    
    /// Default prayer duration in seconds (30, 60, 90, 120, or custom)
    var prayerDurationSeconds: Int
    
    /// Whether notifications are enabled
    var notificationsEnabled: Bool
    
    /// Daily reminder time (if notifications enabled)
    var dailyReminderTime: Date?
    
    /// Whether haptic feedback is enabled
    var hapticFeedbackEnabled: Bool
    
    /// Whether dark mode is forced (nil = system)
    var forceDarkMode: Bool?
    
    /// User's preferred Bible translation reference
    var preferredBibleTranslation: String
    
    /// Date when the user first launched the app
    var firstLaunchDate: Date
    
    /// Whether the user has granted Screen Time permissions
    var hasScreenTimePermission: Bool
    
    /// Whether the user is subscribed
    var isSubscribed: Bool
    
    /// Subscription expiration date (if subscribed)
    var subscriptionExpirationDate: Date?
    
    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        prayerDurationSeconds: Int = 60,
        notificationsEnabled: Bool = false,
        dailyReminderTime: Date? = nil,
        hapticFeedbackEnabled: Bool = true,
        forceDarkMode: Bool? = nil,
        preferredBibleTranslation: String = "NIV",
        firstLaunchDate: Date = Date(),
        hasScreenTimePermission: Bool = false,
        isSubscribed: Bool = false,
        subscriptionExpirationDate: Date? = nil
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.prayerDurationSeconds = prayerDurationSeconds
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.hapticFeedbackEnabled = hapticFeedbackEnabled
        self.forceDarkMode = forceDarkMode
        self.preferredBibleTranslation = preferredBibleTranslation
        self.firstLaunchDate = firstLaunchDate
        self.hasScreenTimePermission = hasScreenTimePermission
        self.isSubscribed = isSubscribed
        self.subscriptionExpirationDate = subscriptionExpirationDate
    }
}

// MARK: - Prayer Duration Options
extension UserSettings {
    static let availableDurations: [Int] = [30, 60, 90, 120, 180, 300]
    
    var formattedDuration: String {
        if prayerDurationSeconds >= 60 {
            let minutes = prayerDurationSeconds / 60
            let seconds = prayerDurationSeconds % 60
            if seconds == 0 {
                return "\(minutes) min"
            }
            return "\(minutes)m \(seconds)s"
        }
        return "\(prayerDurationSeconds)s"
    }
}
