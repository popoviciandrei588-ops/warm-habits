import Foundation
import SwiftUI

// MARK: - Level System
struct LevelSystem {
    static let xpPerPrayer = 25
    static let xpPerStreak = 10
    static let xpBonusFirstPrayer = 50
    
    static func levelForXP(_ xp: Int) -> Int {
        // XP needed: Level 1 = 0, Level 2 = 100, Level 3 = 250, Level 4 = 450, etc.
        var level = 1
        var totalXPNeeded = 0
        while totalXPNeeded <= xp {
            level += 1
            totalXPNeeded += xpForLevel(level)
        }
        return level - 1
    }
    
    static func xpForLevel(_ level: Int) -> Int {
        return level * 100 + (level - 1) * 50
    }
    
    static func xpProgressInLevel(_ xp: Int) -> (current: Int, needed: Int, progress: Double) {
        let currentLevel = levelForXP(xp)
        var xpAtLevelStart = 0
        for l in 1..<currentLevel {
            xpAtLevelStart += xpForLevel(l + 1)
        }
        let xpIntoLevel = xp - xpAtLevelStart
        let xpNeededForNext = xpForLevel(currentLevel + 1)
        let progress = Double(xpIntoLevel) / Double(xpNeededForNext)
        return (xpIntoLevel, xpNeededForNext, min(1.0, max(0, progress)))
    }
    
    static func titleForLevel(_ level: Int) -> String {
        switch level {
        case 1: return "Beginner"
        case 2: return "Seeker"
        case 3: return "Devoted"
        case 4: return "Faithful"
        case 5: return "Disciple"
        case 6: return "Apostle"
        case 7: return "Prophet"
        case 8: return "Saint"
        case 9: return "Enlightened"
        case 10...15: return "Blessed"
        case 16...20: return "Divine"
        case 21...30: return "Angelic"
        default: return "Transcendent"
        }
    }
    
    static func iconForLevel(_ level: Int) -> String {
        switch level {
        case 1: return "leaf.fill"
        case 2: return "sparkle"
        case 3: return "heart.fill"
        case 4: return "flame.fill"
        case 5: return "star.fill"
        case 6: return "crown.fill"
        case 7: return "bolt.fill"
        case 8: return "sun.max.fill"
        case 9: return "moon.stars.fill"
        case 10...15: return "sparkles"
        default: return "wand.and.stars"
        }
    }
}

// MARK: - Achievements
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let requirement: Int
    let xpReward: Int
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    enum AchievementCategory: String, Codable {
        case streak = "Streak"
        case prayers = "Prayers"
        case time = "Time"
        case special = "Special"
    }
}

struct AchievementManager {
    static let allAchievements: [Achievement] = [
        // Streak achievements
        Achievement(id: "streak_3", title: "Getting Started", description: "3-day prayer streak", icon: "flame", category: .streak, requirement: 3, xpReward: 50, isUnlocked: false),
        Achievement(id: "streak_7", title: "Week Warrior", description: "7-day prayer streak", icon: "flame.fill", category: .streak, requirement: 7, xpReward: 100, isUnlocked: false),
        Achievement(id: "streak_14", title: "Fortnight Faith", description: "14-day prayer streak", icon: "flame.circle", category: .streak, requirement: 14, xpReward: 200, isUnlocked: false),
        Achievement(id: "streak_30", title: "Monthly Devotion", description: "30-day prayer streak", icon: "flame.circle.fill", category: .streak, requirement: 30, xpReward: 500, isUnlocked: false),
        Achievement(id: "streak_100", title: "Century of Faith", description: "100-day prayer streak", icon: "laurel.leading", category: .streak, requirement: 100, xpReward: 1000, isUnlocked: false),
        Achievement(id: "streak_365", title: "Year of Prayer", description: "365-day prayer streak", icon: "crown.fill", category: .streak, requirement: 365, xpReward: 5000, isUnlocked: false),
        
        // Prayer count achievements
        Achievement(id: "prayers_1", title: "First Prayer", description: "Complete your first prayer", icon: "hands.clap", category: .prayers, requirement: 1, xpReward: 50, isUnlocked: false),
        Achievement(id: "prayers_10", title: "Finding Peace", description: "Complete 10 prayers", icon: "hands.clap.fill", category: .prayers, requirement: 10, xpReward: 100, isUnlocked: false),
        Achievement(id: "prayers_50", title: "Prayer Habit", description: "Complete 50 prayers", icon: "heart.circle", category: .prayers, requirement: 50, xpReward: 250, isUnlocked: false),
        Achievement(id: "prayers_100", title: "Century Club", description: "Complete 100 prayers", icon: "heart.circle.fill", category: .prayers, requirement: 100, xpReward: 500, isUnlocked: false),
        Achievement(id: "prayers_500", title: "Prayer Master", description: "Complete 500 prayers", icon: "star.circle", category: .prayers, requirement: 500, xpReward: 1500, isUnlocked: false),
        Achievement(id: "prayers_1000", title: "Prayer Legend", description: "Complete 1000 prayers", icon: "star.circle.fill", category: .prayers, requirement: 1000, xpReward: 3000, isUnlocked: false),
        
        // Time achievements
        Achievement(id: "time_30", title: "Half Hour of Peace", description: "Spend 30 minutes in prayer", icon: "clock", category: .time, requirement: 30, xpReward: 100, isUnlocked: false),
        Achievement(id: "time_60", title: "Hour of Devotion", description: "Spend 1 hour in prayer", icon: "clock.fill", category: .time, requirement: 60, xpReward: 200, isUnlocked: false),
        Achievement(id: "time_300", title: "5 Hours of Faith", description: "Spend 5 hours in prayer", icon: "timer", category: .time, requirement: 300, xpReward: 500, isUnlocked: false),
        Achievement(id: "time_600", title: "10 Hours Blessed", description: "Spend 10 hours in prayer", icon: "timer.circle.fill", category: .time, requirement: 600, xpReward: 1000, isUnlocked: false),
        
        // Special achievements
        Achievement(id: "early_bird", title: "Early Bird", description: "Pray before 6 AM", icon: "sunrise.fill", category: .special, requirement: 1, xpReward: 75, isUnlocked: false),
        Achievement(id: "night_owl", title: "Night Owl", description: "Pray after 11 PM", icon: "moon.fill", category: .special, requirement: 1, xpReward: 75, isUnlocked: false),
        Achievement(id: "all_moods", title: "Emotional Journey", description: "Pray with all 5 moods", icon: "heart.text.square.fill", category: .special, requirement: 5, xpReward: 150, isUnlocked: false),
        Achievement(id: "weekend_warrior", title: "Weekend Warrior", description: "Pray on both Saturday and Sunday", icon: "calendar.badge.checkmark", category: .special, requirement: 1, xpReward: 100, isUnlocked: false),
    ]
}

// MARK: - Daily Challenges
struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let type: ChallengeType
    let target: Int
    var progress: Int
    let xpReward: Int
    let date: Date
    
    enum ChallengeType: String, Codable {
        case prayers = "Complete prayers"
        case duration = "Total prayer time"
        case mood = "Pray with specific mood"
        case streak = "Maintain streak"
    }
    
    var isCompleted: Bool {
        progress >= target
    }
    
    var progressPercent: Double {
        min(1.0, Double(progress) / Double(target))
    }
}

struct DailyChallengeGenerator {
    static func generateChallenges(for date: Date) -> [DailyChallenge] {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Seed random with day for consistent daily challenges
        srand48(dayOfYear)
        
        var challenges: [DailyChallenge] = []
        
        // Prayer count challenge
        let prayerCounts = [2, 3, 4, 5]
        let prayerTarget = prayerCounts[Int(drand48() * Double(prayerCounts.count))]
        challenges.append(DailyChallenge(
            id: UUID(),
            title: "Daily Devotion",
            description: "Complete \(prayerTarget) prayers today",
            icon: "hands.clap.fill",
            type: .prayers,
            target: prayerTarget,
            progress: 0,
            xpReward: prayerTarget * 20,
            date: date
        ))
        
        // Duration challenge
        let durations = [3, 5, 10]
        let durationTarget = durations[Int(drand48() * Double(durations.count))]
        challenges.append(DailyChallenge(
            id: UUID(),
            title: "Mindful Minutes",
            description: "Spend \(durationTarget) minutes in prayer",
            icon: "clock.fill",
            type: .duration,
            target: durationTarget,
            progress: 0,
            xpReward: durationTarget * 15,
            date: date
        ))
        
        // Mood challenge
        let moods = PrayerMood.allCases
        let targetMood = moods[Int(drand48() * Double(moods.count))]
        challenges.append(DailyChallenge(
            id: UUID(),
            title: "\(targetMood.rawValue) Focus",
            description: "Pray with \(targetMood.rawValue) mood",
            icon: targetMood.icon,
            type: .mood,
            target: 1,
            progress: 0,
            xpReward: 30,
            date: date
        ))
        
        return challenges
    }
}

// MARK: - Theme System
enum AppTheme: String, CaseIterable, Codable {
    case ocean = "Ocean"
    case sunset = "Sunset"
    case forest = "Forest"
    case lavender = "Lavender"
    case midnight = "Midnight"
    case rose = "Rose"
    
    var primaryColor: Color {
        switch self {
        case .ocean: return Color(red: 0.2, green: 0.5, blue: 0.8)
        case .sunset: return Color(red: 0.95, green: 0.5, blue: 0.3)
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.4)
        case .lavender: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .midnight: return Color(red: 0.2, green: 0.2, blue: 0.4)
        case .rose: return Color(red: 0.9, green: 0.4, blue: 0.5)
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .ocean: return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .sunset: return Color(red: 1.0, green: 0.7, blue: 0.4)
        case .forest: return Color(red: 0.4, green: 0.8, blue: 0.5)
        case .lavender: return Color(red: 0.8, green: 0.6, blue: 0.9)
        case .midnight: return Color(red: 0.4, green: 0.4, blue: 0.7)
        case .rose: return Color(red: 1.0, green: 0.6, blue: 0.7)
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor.opacity(0.15), secondaryColor.opacity(0.1), Color(.systemBackground)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var icon: String {
        switch self {
        case .ocean: return "water.waves"
        case .sunset: return "sun.horizon.fill"
        case .forest: return "leaf.fill"
        case .lavender: return "sparkles"
        case .midnight: return "moon.stars.fill"
        case .rose: return "heart.fill"
        }
    }
}

// MARK: - Timer Style
enum TimerStyle: String, CaseIterable, Codable {
    case circular = "Circular"
    case digital = "Digital"
    case minimal = "Minimal"
    case nature = "Nature"
    
    var icon: String {
        switch self {
        case .circular: return "circle.circle"
        case .digital: return "clock.fill"
        case .minimal: return "minus"
        case .nature: return "leaf.circle"
        }
    }
}

// MARK: - Sound Options
enum PrayerSound: String, CaseIterable, Codable {
    case none = "None"
    case chime = "Gentle Chime"
    case bell = "Meditation Bell"
    case nature = "Nature Sounds"
    case rain = "Soft Rain"
    
    var icon: String {
        switch self {
        case .none: return "speaker.slash"
        case .chime: return "bell"
        case .bell: return "bell.fill"
        case .nature: return "leaf"
        case .rain: return "cloud.rain"
        }
    }
}
