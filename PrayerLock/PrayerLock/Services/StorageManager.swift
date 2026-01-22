import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let settings = "prayerlock.settings"
        static let streak = "prayerlock.streak"
        static let selectedApps = "prayerlock.selectedApps"
        static let lastVerseDate = "prayerlock.lastVerseDate"
        static let prayerHistory = "prayerlock.prayerHistory"
    }
    
    // MARK: - Settings
    func saveSettings(_ settings: UserSettings) {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: Keys.settings)
        }
    }
    
    func loadSettings() -> UserSettings {
        guard let data = defaults.data(forKey: Keys.settings),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings()
        }
        return settings
    }
    
    // MARK: - Streak
    func saveStreak(_ streak: PrayerStreak) {
        if let data = try? JSONEncoder().encode(streak) {
            defaults.set(data, forKey: Keys.streak)
        }
    }
    
    func loadStreak() -> PrayerStreak {
        guard let data = defaults.data(forKey: Keys.streak),
              let streak = try? JSONDecoder().decode(PrayerStreak.self, from: data) else {
            return PrayerStreak()
        }
        return streak
    }
    
    // MARK: - Prayer History
    struct PrayerRecord: Codable {
        let date: Date
        let mood: PrayerMood
        let duration: Int
    }
    
    func savePrayerRecord(mood: PrayerMood, duration: Int) {
        var history = loadPrayerHistory()
        history.append(PrayerRecord(date: Date(), mood: mood, duration: duration))
        
        // Keep only last 100 records
        if history.count > 100 {
            history = Array(history.suffix(100))
        }
        
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: Keys.prayerHistory)
        }
    }
    
    func loadPrayerHistory() -> [PrayerRecord] {
        guard let data = defaults.data(forKey: Keys.prayerHistory),
              let history = try? JSONDecoder().decode([PrayerRecord].self, from: data) else {
            return []
        }
        return history
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        defaults.removeObject(forKey: Keys.settings)
        defaults.removeObject(forKey: Keys.streak)
        defaults.removeObject(forKey: Keys.selectedApps)
        defaults.removeObject(forKey: Keys.lastVerseDate)
        defaults.removeObject(forKey: Keys.prayerHistory)
    }
}
