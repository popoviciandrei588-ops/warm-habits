import SwiftUI
import SwiftData

@main
struct PrayerLockApp: App {
    private let container: ModelContainer

    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var appState = AppState()
    @StateObject private var appBlockingManager = AppBlockingManager()

    init() {
        self.container = ModelContainerFactory.make()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(subscriptionManager)
                .environmentObject(appState)
                .environmentObject(appBlockingManager)
                .modelContainer(container)
                .task {
                    await subscriptionManager.refreshEntitlements()
                }
        }
    }
}

