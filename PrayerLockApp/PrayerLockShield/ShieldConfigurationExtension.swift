import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the standard shield with custom Prayer Lock branding
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.059, green: 0.09, blue: 0.165, alpha: 1.0),
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Complete a 60-second prayer to unlock this app",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Start Prayer",
                color: UIColor(red: 0.118, green: 0.227, blue: 0.373, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: .white,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: UIColor.white.withAlphaComponent(0.6)
            )
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.059, green: 0.09, blue: 0.165, alpha: 1.0),
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Complete a 60-second prayer to unlock this app",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Start Prayer",
                color: UIColor(red: 0.118, green: 0.227, blue: 0.373, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: .white,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: UIColor.white.withAlphaComponent(0.6)
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.059, green: 0.09, blue: 0.165, alpha: 1.0),
            icon: UIImage(systemName: "lock.shield.fill"),
            title: ShieldConfiguration.Label(
                text: "Time to Pray",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Complete a 60-second prayer to unlock this site",
                color: UIColor.white.withAlphaComponent(0.7)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Start Prayer",
                color: UIColor(red: 0.118, green: 0.227, blue: 0.373, alpha: 1.0)
            ),
            primaryButtonBackgroundColor: .white,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Not Now",
                color: UIColor.white.withAlphaComponent(0.6)
            )
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return configuration(shielding: webDomain)
    }
}
