import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the configuration that provides custom UI for blocked apps
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 0.1),
            icon: UIImage(systemName: "hands.clap.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Prayer Lock to complete your prayer and unlock this app.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Prayer Lock",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: .secondaryLabel
            )
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 0.1),
            icon: UIImage(systemName: "hands.clap.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Prayer Lock to complete your prayer and unlock this app.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Prayer Lock",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: .secondaryLabel
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 0.1),
            icon: UIImage(systemName: "hands.clap.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Prayer Lock to complete your prayer and unlock this website.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Prayer Lock",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: .secondaryLabel
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 0.1),
            icon: UIImage(systemName: "hands.clap.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0)
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Prayer Lock to complete your prayer and unlock this website.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Open Prayer Lock",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.376, green: 0.549, blue: 0.898, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: .secondaryLabel
            )
        )
    }
}
