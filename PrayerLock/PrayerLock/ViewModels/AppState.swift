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
    
    private let settingsKey = "prayerlock.settings"
    private let streakKey = "prayerlock.streak"
    
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
    
    func selectMood(_ mood: PrayerMood) {
        settings.selectedMood = mood
        currentPrayer = PrayerCollection.randomPrayer(for: mood)
    }
    
    func completePrayer() {
        streak.recordPrayer()
        isPraying = false
        showPrayerScreen = false
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
        settings.prayerDurationSeconds = max(10, min(300, seconds))
    }
    
    func refreshDailyVerse() {
        dailyVerse = DailyVerseCollection.verseForToday()
    }
    
    func getNewPrayer() {
        currentPrayer = PrayerCollection.randomPrayer(for: settings.selectedMood)
    }
}
