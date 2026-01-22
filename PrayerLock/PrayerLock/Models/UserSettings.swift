import Foundation

struct UserSettings: Codable {
    var prayerDurationSeconds: Int
    var selectedMood: PrayerMood
    var hasCompletedOnboarding: Bool
    var hasGrantedScreenTimePermission: Bool
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    
    init(
        prayerDurationSeconds: Int = 60,
        selectedMood: PrayerMood = .peace,
        hasCompletedOnboarding: Bool = false,
        hasGrantedScreenTimePermission: Bool = false,
        notificationsEnabled: Bool = false,
        dailyReminderTime: Date? = nil
    ) {
        self.prayerDurationSeconds = prayerDurationSeconds
        self.selectedMood = selectedMood
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasGrantedScreenTimePermission = hasGrantedScreenTimePermission
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
    }
}

struct PrayerStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalPrayers: Int
    var lastPrayerDate: Date?
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalPrayers: Int = 0,
        lastPrayerDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalPrayers = totalPrayers
        self.lastPrayerDate = lastPrayerDate
    }
    
    mutating func recordPrayer() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        totalPrayers += 1
        
        if let lastDate = lastPrayerDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let dayDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if dayDifference == 0 {
                // Already prayed today, don't increment streak
                return
            } else if dayDifference == 1 {
                // Consecutive day
                currentStreak += 1
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            // First prayer ever
            currentStreak = 1
        }
        
        lastPrayerDate = Date()
        longestStreak = max(longestStreak, currentStreak)
    }
    
    func hasPrayedToday() -> Bool {
        guard let lastDate = lastPrayerDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
}
