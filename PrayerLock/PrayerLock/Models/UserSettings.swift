import Foundation

struct UserSettings: Codable {
    var prayerDurationSeconds: Int
    var selectedMood: PrayerMood
    var hasCompletedOnboarding: Bool
    var hasGrantedScreenTimePermission: Bool
    var notificationsEnabled: Bool
    var dailyReminderTime: Date?
    
    // Customization
    var theme: AppTheme
    var timerStyle: TimerStyle
    var prayerSound: PrayerSound
    var hapticsEnabled: Bool
    var showConfetti: Bool
    
    // Gamification
    var totalXP: Int
    var unlockedAchievements: [String]
    var moodsUsed: Set<String>
    var dailyChallengesCompleted: Int
    
    init(
        prayerDurationSeconds: Int = 60,
        selectedMood: PrayerMood = .peace,
        hasCompletedOnboarding: Bool = false,
        hasGrantedScreenTimePermission: Bool = false,
        notificationsEnabled: Bool = false,
        dailyReminderTime: Date? = nil,
        theme: AppTheme = .ocean,
        timerStyle: TimerStyle = .circular,
        prayerSound: PrayerSound = .chime,
        hapticsEnabled: Bool = true,
        showConfetti: Bool = true,
        totalXP: Int = 0,
        unlockedAchievements: [String] = [],
        moodsUsed: Set<String> = [],
        dailyChallengesCompleted: Int = 0
    ) {
        self.prayerDurationSeconds = prayerDurationSeconds
        self.selectedMood = selectedMood
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasGrantedScreenTimePermission = hasGrantedScreenTimePermission
        self.notificationsEnabled = notificationsEnabled
        self.dailyReminderTime = dailyReminderTime
        self.theme = theme
        self.timerStyle = timerStyle
        self.prayerSound = prayerSound
        self.hapticsEnabled = hapticsEnabled
        self.showConfetti = showConfetti
        self.totalXP = totalXP
        self.unlockedAchievements = unlockedAchievements
        self.moodsUsed = moodsUsed
        self.dailyChallengesCompleted = dailyChallengesCompleted
    }
}

struct PrayerStreak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalPrayers: Int
    var totalMinutesPrayed: Int
    var lastPrayerDate: Date?
    var prayersByMood: [String: Int]
    var weekendPrayers: (saturday: Bool, sunday: Bool)?
    var todayPrayerCount: Int
    var todayMinutesPrayed: Int
    var lastResetDate: Date?
    
    init(
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        totalPrayers: Int = 0,
        totalMinutesPrayed: Int = 0,
        lastPrayerDate: Date? = nil,
        prayersByMood: [String: Int] = [:],
        weekendPrayers: (saturday: Bool, sunday: Bool)? = nil,
        todayPrayerCount: Int = 0,
        todayMinutesPrayed: Int = 0,
        lastResetDate: Date? = nil
    ) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalPrayers = totalPrayers
        self.totalMinutesPrayed = totalMinutesPrayed
        self.lastPrayerDate = lastPrayerDate
        self.prayersByMood = prayersByMood
        self.todayPrayerCount = todayPrayerCount
        self.todayMinutesPrayed = todayMinutesPrayed
        self.lastResetDate = lastResetDate
    }
    
    // Custom Codable for tuple
    enum CodingKeys: String, CodingKey {
        case currentStreak, longestStreak, totalPrayers, totalMinutesPrayed
        case lastPrayerDate, prayersByMood, todayPrayerCount, todayMinutesPrayed
        case lastResetDate, weekendSaturday, weekendSunday
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        totalPrayers = try container.decode(Int.self, forKey: .totalPrayers)
        totalMinutesPrayed = try container.decodeIfPresent(Int.self, forKey: .totalMinutesPrayed) ?? 0
        lastPrayerDate = try container.decodeIfPresent(Date.self, forKey: .lastPrayerDate)
        prayersByMood = try container.decodeIfPresent([String: Int].self, forKey: .prayersByMood) ?? [:]
        todayPrayerCount = try container.decodeIfPresent(Int.self, forKey: .todayPrayerCount) ?? 0
        todayMinutesPrayed = try container.decodeIfPresent(Int.self, forKey: .todayMinutesPrayed) ?? 0
        lastResetDate = try container.decodeIfPresent(Date.self, forKey: .lastResetDate)
        
        let saturday = try container.decodeIfPresent(Bool.self, forKey: .weekendSaturday)
        let sunday = try container.decodeIfPresent(Bool.self, forKey: .weekendSunday)
        if let sat = saturday, let sun = sunday {
            weekendPrayers = (sat, sun)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(longestStreak, forKey: .longestStreak)
        try container.encode(totalPrayers, forKey: .totalPrayers)
        try container.encode(totalMinutesPrayed, forKey: .totalMinutesPrayed)
        try container.encodeIfPresent(lastPrayerDate, forKey: .lastPrayerDate)
        try container.encode(prayersByMood, forKey: .prayersByMood)
        try container.encode(todayPrayerCount, forKey: .todayPrayerCount)
        try container.encode(todayMinutesPrayed, forKey: .todayMinutesPrayed)
        try container.encodeIfPresent(lastResetDate, forKey: .lastResetDate)
        try container.encodeIfPresent(weekendPrayers?.saturday, forKey: .weekendSaturday)
        try container.encodeIfPresent(weekendPrayers?.sunday, forKey: .weekendSunday)
    }
    
    mutating func recordPrayer(mood: PrayerMood, duration: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Reset daily counters if new day
        if let lastReset = lastResetDate, !calendar.isDate(lastReset, inSameDayAs: today) {
            todayPrayerCount = 0
            todayMinutesPrayed = 0
        }
        lastResetDate = today
        
        totalPrayers += 1
        todayPrayerCount += 1
        
        let minutes = duration / 60
        totalMinutesPrayed += max(1, minutes)
        todayMinutesPrayed += max(1, minutes)
        
        // Track mood usage
        let moodKey = mood.rawValue
        prayersByMood[moodKey] = (prayersByMood[moodKey] ?? 0) + 1
        
        // Track weekend prayers
        let weekday = calendar.component(.weekday, from: Date())
        if weekday == 7 { // Saturday
            weekendPrayers = (true, weekendPrayers?.sunday ?? false)
        } else if weekday == 1 { // Sunday
            weekendPrayers = (weekendPrayers?.saturday ?? false, true)
        }
        
        // Update streak
        if let lastDate = lastPrayerDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let dayDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if dayDifference == 0 {
                // Already prayed today
                lastPrayerDate = Date()
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
