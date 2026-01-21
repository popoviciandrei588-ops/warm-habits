import SwiftUI
import SwiftData

/// Main app entry point
@main
struct PrayerLockApp: App {
    /// SwiftData model container for persistence
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configure the schema with all models
            let schema = Schema([
                UserSettings.self,
                BlockSelection.self,
                PrayerSession.self,
                Streak.self,
                VerseOfDay.self
            ])
            
            // Configure the model container
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
