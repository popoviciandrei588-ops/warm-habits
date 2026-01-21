import DeviceActivity
import ManagedSettings
import FamilyControls

/// Device Activity Monitor Extension for handling scheduled blocking events
/// Note: This would typically be in a separate extension target in a real Xcode project
class PrayerLockDeviceActivityMonitor: DeviceActivityMonitor {
    
    let store = ManagedSettingsStore()
    
    /// Called when a scheduled activity interval begins
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // When the interval starts, apps should already be blocked
        // This is handled by the main app's ScreenTimeManager
        print("Device activity interval started: \(activity.rawValue)")
    }
    
    /// Called when a scheduled activity interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // When the interval ends, remove all shields
        // This happens when the prayer timer completes
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomainCategories = nil
        
        print("Device activity interval ended: \(activity.rawValue)")
    }
    
    /// Called when a warning threshold is reached
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("Device activity interval will start warning: \(activity.rawValue)")
    }
    
    /// Called when a warning threshold for ending is reached
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("Device activity interval will end warning: \(activity.rawValue)")
    }
    
    /// Called when an event threshold is reached
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("Event threshold reached: \(event.rawValue) for activity: \(activity.rawValue)")
    }
    
    /// Called when a warning for an event threshold is reached
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        print("Event will reach threshold warning: \(event.rawValue)")
    }
}

// MARK: - Shield Configuration
/// Custom shield configuration provider
/// Note: This would typically be in a ShieldConfiguration extension target
class PrayerLockShieldConfiguration {
    
    /// Get the shield configuration for blocked apps
    static func configuration(for application: ApplicationToken?) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: .systemBackground,
            icon: nil,
            title: ShieldConfiguration.Label(text: "Time to Pray", color: .label),
            subtitle: ShieldConfiguration.Label(text: "Complete a prayer to unlock this app", color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Open Prayer Lock", color: .white),
            primaryButtonBackgroundColor: .systemIndigo,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Not Now", color: .systemIndigo)
        )
    }
    
    /// Get the shield configuration for blocked categories
    static func configuration(for category: ActivityCategoryToken?) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: .systemBackground,
            icon: nil,
            title: ShieldConfiguration.Label(text: "Time to Pray", color: .label),
            subtitle: ShieldConfiguration.Label(text: "Complete a prayer to unlock this category", color: .secondaryLabel),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Open Prayer Lock", color: .white),
            primaryButtonBackgroundColor: .systemIndigo,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Not Now", color: .systemIndigo)
        )
    }
}
