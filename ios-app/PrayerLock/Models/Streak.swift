import Foundation
import SwiftData

@Model
final class Streak {
    var currentStreak: Int
    var lastPrayerDate: Date
    var totalSessions: Int
    var totalTimePrayed: Int // in seconds
    
    init(currentStreak: Int = 0, lastPrayerDate: Date = Date(), totalSessions: Int = 0, totalTimePrayed: Int = 0) {
        self.currentStreak = currentStreak
        self.lastPrayerDate = lastPrayerDate
        self.totalSessions = totalSessions
        self.totalTimePrayed = totalTimePrayed
    }
}
