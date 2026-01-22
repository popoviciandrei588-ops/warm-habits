import SwiftUI
import SwiftData

@main
struct PrayerLockApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var blockingManager = BlockingManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PrayerSession.self,
            DailyStreak.self,
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(subscriptionManager)
                .environmentObject(blockingManager)
                .preferredColorScheme(appState.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
