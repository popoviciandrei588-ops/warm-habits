import Foundation
import SwiftData

@Model
final class UserSettings {
    var id: UUID
    var prayerDuration: Int
    var unlockWindowMinutes: Int
    var dailyReminderEnabled: Bool
    var dailyReminderTime: Date?
    var hasActiveSubscription: Bool
    var subscriptionExpiresAt: Date?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        prayerDuration: Int = 60,
        unlockWindowMinutes: Int = 10,
        dailyReminderEnabled: Bool = false,
        dailyReminderTime: Date? = nil,
        hasActiveSubscription: Bool = false,
        subscriptionExpiresAt: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.prayerDuration = prayerDuration
        self.unlockWindowMinutes = unlockWindowMinutes
        self.dailyReminderEnabled = dailyReminderEnabled
        self.dailyReminderTime = dailyReminderTime
        self.hasActiveSubscription = hasActiveSubscription
        self.subscriptionExpiresAt = subscriptionExpiresAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
