import SwiftUI
import FamilyControls

@main
struct PrayerLockApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var screenTimeManager = ScreenTimeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(screenTimeManager)
        }
    }
}
