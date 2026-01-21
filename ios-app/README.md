# Prayer Lock - iOS App Clone

This directory contains the source code for the "Prayer Lock" iOS app clone.

## Project Structure

- **App/**: Contains the main entry point `PrayerLockApp.swift` and `ContentView.swift`.
- **Models/**: SwiftData models (`PrayerSession`, `Streak`, etc.).
- **Managers/**: Core logic for Screen Time (`ScreenTimeManager`), StoreKit (`StoreKitManager`), and Prayers (`PrayerComposer`).
- **Views/**: SwiftUI views organized by flow (Onboarding, Core, Settings).
- **Extensions/**: Stubs for DeviceActivityMonitor and ShieldConfiguration extensions.

## Setup Instructions

1. **Create a new Xcode Project**:
   - Open Xcode and create a new App project.
   - Choose SwiftUI and SwiftData.
   - Target iOS 17+.

2. **Add Capabilities**:
   - Add "Family Controls" capability.
   - Add "In-App Purchase" capability.

3. **Add Extensions**:
   - Add a "Device Activity Monitor Extension" target.
   - Add a "Shield Configuration Extension" target.

4. **Copy Files**:
   - Copy the contents of the `PrayerLock` folder into your Xcode project's main group.
   - Move `Extensions/DeviceActivityMonitorExtension.swift` to the Monitor Extension target.
   - Move `Extensions/ShieldConfigurationExtension.swift` to the Shield Configuration Extension target.

5. **Configuration**:
   - Ensure the Bundle IDs match for App Groups if sharing data (not strictly implemented here but good practice).
   - Set up the Product IDs in `StoreKitManager.swift` to match your App Store Connect configuration (or StoreKit Configuration file).

## Features Implemented

- **Onboarding**: Explains concept, requests permissions, picks apps.
- **Mood Selection**: Simple UI to pick mood.
- **Prayer Generation**: Returns prayer based on mood.
- **Timer (Lock)**: 60s countdown that shields apps during prayer and unshields after.
- **Paywall**: Mock StoreKit 2 implementation.
- **Stats**: Simple view showing session history.
