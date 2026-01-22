# Prayer Lock - Christian Focus App

A SwiftUI iOS app that helps users pause and pray before opening distracting apps. Inspired by "Prayer Lock: Christian Focus".

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)

## Features

### Core Functionality
- **App Blocking**: Block selected apps using Apple's Screen Time APIs (FamilyControls + ManagedSettings)
- **Prayer Timer**: 60-second countdown prayer session (customizable from 30s to 5 minutes)
- **Prayer Moods**: Choose from Gratitude, Peace, Strength, Hope, or Forgiveness
- **Bible-style Prayers**: Curated prayers with matching Bible verses for each mood

### Additional Features
- **Prayer Streak**: Track consecutive days of prayer
- **Daily Bible Verse**: New verse every day with sharing capability
- **Statistics**: Total prayers, longest streak, time spent in prayer
- **Achievements**: Unlock badges for milestones
- **Beautiful UI**: Calming, minimal design with smooth animations

## Screenshots

The app includes:
1. **Onboarding Flow** - Explains the concept and requests permissions
2. **Home Screen** - Quick stats, mood selector, and pray button
3. **Prayer Session** - Calming timer with prayer text
4. **Daily Verse** - Scripture for daily reflection
5. **Stats & Achievements** - Track your prayer journey
6. **Settings** - Customize prayer duration and manage blocked apps

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Apple Developer account (for FamilyControls capability)

## Setup Instructions

### 1. Open in Xcode

1. Navigate to the `PrayerLock` folder
2. Open `PrayerLock.xcodeproj` in Xcode

### 2. Configure Signing & Capabilities

1. Select the project in the Navigator
2. Select the "PrayerLock" target
3. Go to "Signing & Capabilities"
4. Set your Development Team
5. Ensure "Family Controls" capability is added

### 3. Add the Shield Configuration Extension (Optional but Recommended)

For custom shield UI when blocked apps are opened:

1. In Xcode, go to File > New > Target
2. Choose "Shield Configuration Extension"
3. Name it "PrayerLockShield"
4. Copy the content from `PrayerLockShield/ShieldConfigurationExtension.swift`
5. Add the Family Controls capability to the extension

### 4. Request Family Controls Entitlement

**Important**: The FamilyControls framework requires a special entitlement from Apple.

1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Navigate to Certificates, Identifiers & Profiles
3. Select your App ID
4. Enable "Family Controls" capability
5. You may need to request access if it's not available

### 5. Build and Run

1. Connect your iOS device (Screen Time APIs don't work in Simulator)
2. Select your device as the build target
3. Build and run (⌘R)

## Project Structure

```
PrayerLock/
├── PrayerLock.xcodeproj
├── PrayerLock/
│   ├── PrayerLockApp.swift          # App entry point
│   ├── Info.plist                    # App configuration
│   ├── PrayerLock.entitlements       # Family Controls entitlement
│   │
│   ├── Views/
│   │   ├── ContentView.swift         # Main content router
│   │   ├── OnboardingView.swift      # First-launch setup
│   │   ├── HomeView.swift            # Main dashboard
│   │   ├── PrayerSessionView.swift   # Prayer timer screen
│   │   ├── DailyVerseView.swift      # Bible verse display
│   │   ├── StatsView.swift           # Statistics & achievements
│   │   └── SettingsView.swift        # App settings
│   │
│   ├── Models/
│   │   ├── Prayer.swift              # Prayer & mood models
│   │   ├── BibleVerse.swift          # Verse collection
│   │   └── UserSettings.swift        # Settings & streak models
│   │
│   ├── ViewModels/
│   │   └── AppState.swift            # Global app state
│   │
│   ├── Services/
│   │   ├── ScreenTimeManager.swift   # Screen Time API wrapper
│   │   └── StorageManager.swift      # Local storage
│   │
│   └── Resources/
│       └── Assets.xcassets/          # Colors and app icon
│
└── PrayerLockShield/                  # Shield extension (optional)
    ├── ShieldConfigurationExtension.swift
    ├── Info.plist
    └── PrayerLockShield.entitlements
```

## How It Works

### Screen Time Integration

The app uses three Apple frameworks:
- **FamilyControls**: Request authorization and select apps to block
- **ManagedSettings**: Apply shields to selected applications
- **DeviceActivity** (optional): Monitor device activity

### Flow

1. User grants Screen Time permission
2. User selects apps to block
3. When a blocked app is opened, iOS shows a shield
4. User opens Prayer Lock and completes a prayer
5. Apps are temporarily unblocked for 1 hour

## Customization

### Adding More Prayers

Edit `Models/Prayer.swift` and add entries to the `PrayerCollection.prayers` dictionary.

### Adding More Bible Verses

Edit `Models/BibleVerse.swift` and add entries to the `DailyVerseCollection.verses` array.

### Changing Colors

Edit the color sets in `Resources/Assets.xcassets/` or modify the colors directly in the views.

## Troubleshooting

### "Family Controls not available"
- Ensure you're running on a physical device, not the simulator
- Check that your Apple Developer account has the Family Controls entitlement

### "Authorization denied"
- The user must be signed into iCloud
- Screen Time must be enabled in device settings
- For children's devices, parents must approve via Family Sharing

### Build errors about missing frameworks
- Ensure deployment target is iOS 17.0+
- Clean build folder (⇧⌘K) and rebuild

## Privacy

This app:
- Stores all data locally on the device
- Does not collect or transmit any personal information
- Uses Screen Time APIs for app blocking only

## License

This project is for educational purposes. Feel free to use and modify.

## Acknowledgments

- Inspired by "Prayer Lock: Christian Focus" app
- Bible verses from various translations
- Built with SwiftUI and Apple's Screen Time APIs
