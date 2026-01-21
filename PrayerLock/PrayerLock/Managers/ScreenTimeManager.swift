import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

/// Manager for handling Screen Time API interactions
/// Handles app selection, shielding (blocking), and unblocking
@MainActor
final class ScreenTimeManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ScreenTimeManager()
    
    // MARK: - Published Properties
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isBlocking: Bool = false
    @Published var error: ScreenTimeError?
    
    // MARK: - Private Properties
    private let authorizationCenter = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    
    // MARK: - Constants
    private let activityName = DeviceActivityName("prayerlock.blocking.session")
    private let shieldConfigurationDataSource = "PrayerLockShieldConfiguration"
    
    // MARK: - Initialization
    private init() {
        // Check initial authorization status
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// Request Screen Time authorization from the user
    func requestAuthorization() async -> Bool {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            await checkAuthorizationStatus()
            return authorizationStatus == .approved
        } catch {
            self.error = .authorizationFailed(error)
            return false
        }
    }
    
    /// Check the current authorization status
    func checkAuthorizationStatus() async {
        switch authorizationCenter.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .denied:
            authorizationStatus = .denied
        case .approved:
            authorizationStatus = .approved
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    // MARK: - App Selection
    
    /// Update the selected apps and categories to block
    func updateSelection(_ selection: FamilyActivitySelection) {
        selectedApps = selection
    }
    
    /// Get the count of selected items
    var selectedCount: Int {
        selectedApps.applicationTokens.count + selectedApps.categoryTokens.count
    }
    
    /// Check if any apps are selected
    var hasSelection: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }
    
    // MARK: - Blocking (Shielding)
    
    /// Start blocking the selected apps (apply shield)
    func startBlocking() {
        guard hasSelection else {
            error = .noAppsSelected
            return
        }
        
        // Apply application shields
        store.shield.applications = selectedApps.applicationTokens.isEmpty ? nil : selectedApps.applicationTokens
        
        // Apply category shields
        store.shield.applicationCategories = selectedApps.categoryTokens.isEmpty ? nil :
            ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
        
        // Apply web domain shields for categories
        store.shield.webDomainCategories = selectedApps.categoryTokens.isEmpty ? nil :
            ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
        
        isBlocking = true
    }
    
    /// Stop blocking all apps (remove shield)
    func stopBlocking() {
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        
        isBlocking = false
    }
    
    /// Toggle blocking state
    func toggleBlocking() {
        if isBlocking {
            stopBlocking()
        } else {
            startBlocking()
        }
    }
    
    // MARK: - Scheduled Blocking with DeviceActivity
    
    /// Schedule a device activity monitoring session
    func scheduleBlockingSession(duration: TimeInterval) {
        guard hasSelection else {
            error = .noAppsSelected
            return
        }
        
        // Create a schedule for the blocking session
        let now = Date()
        let endDate = now.addingTimeInterval(duration)
        
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endDate)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        do {
            // Start monitoring the activity
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            startBlocking()
        } catch {
            self.error = .schedulingFailed(error)
        }
    }
    
    /// Stop the scheduled blocking session
    func stopScheduledSession() {
        deviceActivityCenter.stopMonitoring([activityName])
        stopBlocking()
    }
    
    // MARK: - Advanced Shield Configuration
    
    /// Apply shield with custom configuration
    func applyShieldWithConfiguration(message: String? = nil) {
        guard hasSelection else {
            error = .noAppsSelected
            return
        }
        
        // Apply shields to selected apps
        store.shield.applications = selectedApps.applicationTokens.isEmpty ? nil : selectedApps.applicationTokens
        
        // Apply shields to selected categories
        store.shield.applicationCategories = selectedApps.categoryTokens.isEmpty ? nil :
            ShieldSettings.ActivityCategoryPolicy.specific(selectedApps.categoryTokens)
        
        isBlocking = true
    }
    
    // MARK: - Utility Methods
    
    /// Clear all managed settings
    func clearAllSettings() {
        store.clearAllSettings()
        isBlocking = false
    }
    
    /// Reset the manager state
    func reset() {
        stopBlocking()
        selectedApps = FamilyActivitySelection()
    }
}

// MARK: - Authorization Status
extension ScreenTimeManager {
    enum AuthorizationStatus: String {
        case notDetermined = "Not Determined"
        case denied = "Denied"
        case approved = "Approved"
        
        var isAuthorized: Bool {
            self == .approved
        }
        
        var systemDescription: String {
            switch self {
            case .notDetermined:
                return "Screen Time permission has not been requested yet."
            case .denied:
                return "Screen Time permission was denied. Please enable it in Settings."
            case .approved:
                return "Screen Time permission is granted."
            }
        }
    }
}

// MARK: - Screen Time Errors
enum ScreenTimeError: LocalizedError {
    case authorizationFailed(Error)
    case noAppsSelected
    case schedulingFailed(Error)
    case shieldingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let error):
            return "Authorization failed: \(error.localizedDescription)"
        case .noAppsSelected:
            return "No apps selected for blocking. Please select at least one app."
        case .schedulingFailed(let error):
            return "Failed to schedule blocking session: \(error.localizedDescription)"
        case .shieldingFailed(let error):
            return "Failed to apply app shield: \(error.localizedDescription)"
        }
    }
}

// MARK: - DeviceActivityName Extension
extension DeviceActivityName {
    static let prayerLockSession = DeviceActivityName("prayerlock.blocking.session")
}
