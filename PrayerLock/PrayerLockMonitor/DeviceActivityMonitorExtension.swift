import DeviceActivity
import ManagedSettings
import Foundation

// Monitor device activity for scheduling and events
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // When a scheduled blocking interval starts, apply the shield
        if activity == .dailyBlocking {
            applyShield()
        }
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // When a scheduled blocking interval ends, remove the shield
        if activity == .dailyBlocking {
            removeShield()
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle when usage thresholds are reached
        if event == .prayerRequired {
            applyShield()
        }
    }
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Optional: Send a notification warning that blocking will start soon
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Optional: Send a notification warning that blocking will end soon
    }
    
    // MARK: - Shield Management
    
    private func applyShield() {
        // Load saved app selection
        if let data = UserDefaults(suiteName: "group.com.prayerlock.shared")?.data(forKey: "selectedApps"),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
            store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        }
    }
    
    private func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}

// MARK: - Device Activity Names
extension DeviceActivityName {
    static let dailyBlocking = Self("dailyBlocking")
    static let prayerSession = Self("prayerSession")
}

// MARK: - Device Activity Event Names
extension DeviceActivityEvent.Name {
    static let prayerRequired = Self("prayerRequired")
    static let unlockExpired = Self("unlockExpired")
}
