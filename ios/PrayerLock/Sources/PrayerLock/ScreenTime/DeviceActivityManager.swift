import Foundation
import DeviceActivity

/// Optional monitoring hooks for a “lock session”.
///
/// NOTE: `DeviceActivitySchedule` is time-of-day based (typically repeating).
/// The extension target (`PrayerLockDeviceActivityMonitorExtension`) is where you
/// can enforce shielding even if the main app is killed.
@MainActor
final class DeviceActivityManager: ObservableObject {
    static let activityName = DeviceActivityName("PrayerLockLockSession")
    private let center = DeviceActivityCenter()

    func startMonitoringLock(durationSeconds: Int) {
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(durationSeconds))

        let cal = Calendar.current
        let startComponents = cal.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = cal.dateComponents([.hour, .minute, .second], from: end)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )

        do {
            try center.startMonitoring(Self.activityName, during: schedule)
        } catch {
            // Best-effort; shielding still works without monitoring.
        }
    }

    func stopMonitoringLock() {
        center.stopMonitoring([Self.activityName])
    }
}

