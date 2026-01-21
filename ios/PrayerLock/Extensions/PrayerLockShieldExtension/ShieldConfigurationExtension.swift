import ManagedSettingsUI
import SwiftUI

/// Add this file to a ShieldConfiguration extension target named `PrayerLockShieldExtension`.
///
/// The system shows this UI when a shielded app is opened.
final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: .systemBackground,
            icon: .init(systemName: "lock.shield"),
            title: .init(text: "Pause & Pray"),
            subtitle: .init(text: "This app is locked until you complete a short prayer."),
            primaryButtonLabel: .init(text: "Open PrayerLock"),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: .init(text: "Not now")
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundColor: .systemBackground,
            icon: .init(systemName: "lock.shield"),
            title: .init(text: "Pause & Pray"),
            subtitle: .init(text: "This category is locked until you complete a short prayer."),
            primaryButtonLabel: .init(text: "Open PrayerLock"),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: .init(text: "Not now")
        )
    }
}

