import ManagedSettings
import ManagedSettingsUI
import UIKit

// This code belongs in a Shield Configuration Extension target
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield appearance
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.black,
            icon: UIImage(systemName: "hands.sparkles.fill"),
            title: ShieldConfiguration.Label(text: "Prayer Lock", color: .white),
            subtitle: ShieldConfiguration.Label(text: "Pause. Pray. Unlock.", color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Pray to Unlock", color: .white),
            primaryButtonBackgroundColor: .blue,
            secondaryButtonLabel: nil
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Similar configuration for categories
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.black,
            title: ShieldConfiguration.Label(text: "Prayer Lock", color: .white),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Pray to Unlock", color: .white),
            primaryButtonBackgroundColor: .blue
        )
    }
}
