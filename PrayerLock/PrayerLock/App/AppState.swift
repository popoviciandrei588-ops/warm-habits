import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("prayerDuration") var prayerDuration: Int = 60
    @AppStorage("unlockWindow") var unlockWindow: Int = 10
    @AppStorage("dailyReminderEnabled") var dailyReminderEnabled: Bool = false
    @AppStorage("dailyReminderTime") var dailyReminderTime: Double = 32400 // 9:00 AM in seconds
    
    @Published var currentFlow: AppFlow = .main
    @Published var showPaywall: Bool = false
    @Published var isUnlocked: Bool = false
    @Published var unlockExpiresAt: Date?
    
    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : nil
    }
    
    enum AppFlow {
        case onboarding
        case main
        case prayerFlow
        case blocked
    }
    
    init() {
        checkUnlockStatus()
    }
    
    func checkUnlockStatus() {
        if let expiresAt = unlockExpiresAt, expiresAt > Date() {
            isUnlocked = true
        } else {
            isUnlocked = false
            unlockExpiresAt = nil
        }
    }
    
    func unlockApps() {
        let duration = TimeInterval(unlockWindow * 60)
        unlockExpiresAt = Date().addingTimeInterval(duration)
        isUnlocked = true
    }
    
    func lockApps() {
        isUnlocked = false
        unlockExpiresAt = nil
    }
}
