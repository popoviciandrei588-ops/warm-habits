import Foundation
import SwiftData

/// Model for tracking prayer streaks
@Model
final class Streak {
    /// Unique identifier
    var id: UUID
    
    /// Current streak count (consecutive days)
    var currentStreak: Int
    
    /// Longest streak ever achieved
    var longestStreak: Int
    
    /// Last date a prayer was completed
    var lastPrayerDate: Date?
    
    /// Total number of prayers completed
    var totalPrayers: Int
    
    /// Total seconds spent in prayer
    var totalSecondsInPrayer: Int
    
    /// Dates of all prayers (for calendar display)
    var prayerDates: [Date]
    
    /// Session counts by mood (stored as dictionary)
    var moodCountsData: Data?
    
    init(
        id: UUID = UUID(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastPrayerDate: Date? = nil,
        totalPrayers: Int = 0,
        totalSecondsInPrayer: Int = 0,
        prayerDates: [Date] = [],
        moodCountsData: Data? = nil
    ) {
        self.id = id
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastPrayerDate = lastPrayerDate
        self.totalPrayers = totalPrayers
        self.totalSecondsInPrayer = totalSecondsInPrayer
        self.prayerDates = prayerDates
        self.moodCountsData = moodCountsData
    }
    
    /// Record a new prayer session
    func recordPrayer(date: Date = Date(), duration: Int, mood: Mood) {
        totalPrayers += 1
        totalSecondsInPrayer += duration
        prayerDates.append(date)
        
        // Update mood counts
        var counts = moodCounts
        counts[mood.rawValue, default: 0] += 1
        storeMoodCounts(counts)
        
        // Update streak
        updateStreak(for: date)
    }
    
    /// Update the streak based on the prayer date
    private func updateStreak(for date: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        if let lastDate = lastPrayerDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 0 {
                // Same day, streak continues
            } else if daysDifference == 1 {
                // Consecutive day, increment streak
                currentStreak += 1
            } else {
                // Streak broken, reset to 1
                currentStreak = 1
            }
        } else {
            // First prayer ever
            currentStreak = 1
        }
        
        // Update longest streak if needed
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastPrayerDate = date
    }
    
    /// Check if streak is still valid (called when app opens)
    func checkStreakValidity() {
        guard let lastDate = lastPrayerDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysDifference = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
        
        if daysDifference > 1 {
            // Streak is broken
            currentStreak = 0
        }
    }
    
    /// Get mood counts dictionary
    var moodCounts: [String: Int] {
        guard let data = moodCountsData else { return [:] }
        do {
            return try JSONDecoder().decode([String: Int].self, from: data)
        } catch {
            return [:]
        }
    }
    
    /// Store mood counts dictionary
    func storeMoodCounts(_ counts: [String: Int]) {
        do {
            moodCountsData = try JSONEncoder().encode(counts)
        } catch {
            print("Failed to encode mood counts: \(error)")
        }
    }
}

// MARK: - Formatted Statistics
extension Streak {
    /// Format total prayer time as a readable string
    var formattedTotalTime: String {
        let hours = totalSecondsInPrayer / 3600
        let minutes = (totalSecondsInPrayer % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(totalSecondsInPrayer) sec"
        }
    }
    
    /// Get the most common mood
    var mostCommonMood: Mood? {
        let counts = moodCounts
        guard let maxEntry = counts.max(by: { $0.value < $1.value }) else { return nil }
        return Mood(rawValue: maxEntry.key)
    }
    
    /// Check if the user has prayed today
    var hasPrayedToday: Bool {
        guard let lastDate = lastPrayerDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    /// Get prayers for a specific month
    func prayersInMonth(year: Int, month: Int) -> [Date] {
        let calendar = Calendar.current
        return prayerDates.filter { date in
            let components = calendar.dateComponents([.year, .month], from: date)
            return components.year == year && components.month == month
        }
    }
}
