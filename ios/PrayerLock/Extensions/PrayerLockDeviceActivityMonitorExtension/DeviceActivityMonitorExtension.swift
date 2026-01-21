import DeviceActivity
import ManagedSettings
import FamilyControls

/// Add this file to a Device Activity Monitor extension target named
/// `PrayerLockDeviceActivityMonitorExtension`.
///
/// This extension is where you can re-apply shielding if the main app is killed.
final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("PrayerLockStore"))

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // In a production app, read the persisted `FamilyActivitySelection` from an App Group
        // and apply the same shielding here.
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Optionally clear shielding when the monitored interval ends.
        // For “lock-until-prayer-completes”, you typically *do not* auto-clear here.
        _ = store // keep reference; intentionally no-op by default.
    }
}

