import SwiftUI
import SwiftData

@main
struct PrayerLockApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [PrayerSession.self, Streak.self, VerseOfDay.self, UserSettings.self])
        }
    }
}
