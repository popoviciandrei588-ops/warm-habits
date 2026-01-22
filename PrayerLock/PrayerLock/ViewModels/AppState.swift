import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var settings: UserSettings {
        didSet { saveSettings() }
    }
    @Published var streak: PrayerStreak {
        didSet { saveStreak() }
    }
    @Published var currentPrayer: Prayer?
    @Published var dailyVerse: BibleVerse
    @Published var showPrayerScreen: Bool = false
    @Published var isPraying: Bool = false
    
    // Gamification
    @Published var achievements: [Achievement]
    @Published var dailyChallenges: [DailyChallenge]
    @Published var showLevelUp: Bool = false
    @Published var newLevel: Int = 1
    @Published var showAchievement: Bool = false
    @Published var newAchievement: Achievement?
    @Published var showConfetti: Bool = false
    
    private let settingsKey = "prayerlock.settings"
    private let streakKey = "prayerlock.streak"
    private let achievementsKey = "prayerlock.achievements"
    private let challengesKey = "prayerlock.challenges"
    private let challengesDateKey = "prayerlock.challengesDate"
    
    var currentLevel: Int {
        LevelSystem.levelForXP(settings.totalXP)
    }
    
    var levelProgress: (current: Int, needed: Int, progress: Double) {
        LevelSystem.xpProgressInLevel(settings.totalXP)
    }
    
    var levelTitle: String {
        LevelSystem.titleForLevel(currentLevel)
    }
    
    init() {
        // Load settings
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.settings = settings
        } else {
            self.settings = UserSettings()
        }
        
        // Load streak
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let streak = try? JSONDecoder().decode(PrayerStreak.self, from: data) {
            self.streak = streak
        } else {
            self.streak = PrayerStreak()
        }
        
        // Load achievements
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let achievements = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = achievements
        } else {
            self.achievements = AchievementManager.allAchievements
        }
        
        // Load or generate daily challenges
        let today = Calendar.current.startOfDay(for: Date())
        if let savedDate = UserDefaults.standard.object(forKey: challengesDateKey) as? Date,
           Calendar.current.isDate(savedDate, inSameDayAs: today),
           let data = UserDefaults.standard.data(forKey: challengesKey),
           let challenges = try? JSONDecoder().decode([DailyChallenge].self, from: data) {
            self.dailyChallenges = challenges
        } else {
            self.dailyChallenges = DailyChallengeGenerator.generateChallenges(for: today)
            saveChallenges()
        }
        
        // Get daily verse
        self.dailyVerse = DailyVerseCollection.verseForToday()
        
        // Set initial prayer based on mood
        self.currentPrayer = PrayerCollection.randomPrayer(for: settings.selectedMood)
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: settingsKey)
        }
    }
    
    private func saveStreak() {
        if let data = try? JSONEncoder().encode(streak) {
            UserDefaults.standard.set(data, forKey: streakKey)
        }
    }
    
    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
    }
    
    private func saveChallenges() {
        if let data = try? JSONEncoder().encode(dailyChallenges) {
            UserDefaults.standard.set(data, forKey: challengesKey)
            UserDefaults.standard.set(Date(), forKey: challengesDateKey)
        }
    }
    
    func selectMood(_ mood: PrayerMood) {
        settings.selectedMood = mood
        currentPrayer = PrayerCollection.randomPrayer(for: mood)
    }
    
    func completePrayer() {
        let previousLevel = currentLevel
        let mood = settings.selectedMood
        let duration = settings.prayerDurationSeconds
        
        // Record the prayer
        streak.recordPrayer(mood: mood, duration: duration)
        
        // Add XP
        var earnedXP = LevelSystem.xpPerPrayer
        earnedXP += streak.currentStreak * LevelSystem.xpPerStreak
        if streak.totalPrayers == 1 {
            earnedXP += LevelSystem.xpBonusFirstPrayer
        }
        settings.totalXP += earnedXP
        
        // Track mood usage
        settings.moodsUsed.insert(mood.rawValue)
        
        // Update daily challenges
        updateChallenges(mood: mood, duration: duration)
        
        // Check achievements
        checkAchievements()
        
        // Check for level up
        let newLevelValue = currentLevel
        if newLevelValue > previousLevel {
            newLevel = newLevelValue
            showLevelUp = true
        }
        
        // Show confetti
        if settings.showConfetti {
            showConfetti = true
        }
        
        isPraying = false
        showPrayerScreen = false
    }
    
    private func updateChallenges(mood: PrayerMood, duration: Int) {
        for i in 0..<dailyChallenges.count {
            switch dailyChallenges[i].type {
            case .prayers:
                dailyChallenges[i].progress += 1
            case .duration:
                dailyChallenges[i].progress += duration / 60
            case .mood:
                if dailyChallenges[i].description.contains(mood.rawValue) {
                    dailyChallenges[i].progress = 1
                }
            case .streak:
                dailyChallenges[i].progress = streak.currentStreak
            }
            
            // Award XP for completed challenges
            if dailyChallenges[i].isCompleted && dailyChallenges[i].progress == dailyChallenges[i].target {
                settings.totalXP += dailyChallenges[i].xpReward
                settings.dailyChallengesCompleted += 1
            }
        }
        saveChallenges()
    }
    
    private func checkAchievements() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        for i in 0..<achievements.count {
            guard !achievements[i].isUnlocked else { continue }
            
            var shouldUnlock = false
            
            switch achievements[i].id {
            // Streak achievements
            case "streak_3": shouldUnlock = streak.currentStreak >= 3
            case "streak_7": shouldUnlock = streak.currentStreak >= 7
            case "streak_14": shouldUnlock = streak.currentStreak >= 14
            case "streak_30": shouldUnlock = streak.currentStreak >= 30
            case "streak_100": shouldUnlock = streak.currentStreak >= 100
            case "streak_365": shouldUnlock = streak.currentStreak >= 365
                
            // Prayer count achievements
            case "prayers_1": shouldUnlock = streak.totalPrayers >= 1
            case "prayers_10": shouldUnlock = streak.totalPrayers >= 10
            case "prayers_50": shouldUnlock = streak.totalPrayers >= 50
            case "prayers_100": shouldUnlock = streak.totalPrayers >= 100
            case "prayers_500": shouldUnlock = streak.totalPrayers >= 500
            case "prayers_1000": shouldUnlock = streak.totalPrayers >= 1000
                
            // Time achievements
            case "time_30": shouldUnlock = streak.totalMinutesPrayed >= 30
            case "time_60": shouldUnlock = streak.totalMinutesPrayed >= 60
            case "time_300": shouldUnlock = streak.totalMinutesPrayed >= 300
            case "time_600": shouldUnlock = streak.totalMinutesPrayed >= 600
                
            // Special achievements
            case "early_bird": shouldUnlock = hour < 6
            case "night_owl": shouldUnlock = hour >= 23
            case "all_moods": shouldUnlock = settings.moodsUsed.count >= 5
            case "weekend_warrior":
                if let weekend = streak.weekendPrayers {
                    shouldUnlock = weekend.saturday && weekend.sunday
                }
                
            default: break
            }
            
            if shouldUnlock {
                achievements[i].isUnlocked = true
                achievements[i].unlockedDate = Date()
                settings.totalXP += achievements[i].xpReward
                settings.unlockedAchievements.append(achievements[i].id)
                
                // Show achievement notification
                newAchievement = achievements[i]
                showAchievement = true
            }
        }
        saveAchievements()
    }
    
    func startPrayer() {
        currentPrayer = PrayerCollection.randomPrayer(for: settings.selectedMood)
        isPraying = true
        showPrayerScreen = true
    }
    
    func completeOnboarding() {
        settings.hasCompletedOnboarding = true
    }
    
    func updatePrayerDuration(_ seconds: Int) {
        settings.prayerDurationSeconds = max(10, min(600, seconds))
    }
    
    func refreshDailyVerse() {
        dailyVerse = DailyVerseCollection.verseForToday()
    }
    
    func getNewPrayer() {
        currentPrayer = PrayerCollection.randomPrayer(for: settings.selectedMood)
    }
    
    func setTheme(_ theme: AppTheme) {
        settings.theme = theme
    }
    
    func setTimerStyle(_ style: TimerStyle) {
        settings.timerStyle = style
    }
    
    func resetAllData() {
        settings = UserSettings()
        streak = PrayerStreak()
        achievements = AchievementManager.allAchievements
        dailyChallenges = DailyChallengeGenerator.generateChallenges(for: Date())
        saveSettings()
        saveStreak()
        saveAchievements()
        saveChallenges()
    }
}
