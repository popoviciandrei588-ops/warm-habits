# Prayer Lock - Christian Focus App

A beautiful, gamified iOS SwiftUI app that helps users pause and pray before opening distracting apps. Inspired by "Prayer Lock: Christian Focus" and prayerlock.com.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)

## Features

### Core Functionality
- **App Blocking**: Block selected apps using Apple's Screen Time APIs (FamilyControls + ManagedSettings)
- **Prayer Timer**: Customizable prayer duration (30s - 5 minutes)
- **Multiple Timer Styles**: Circular, Digital, Minimal, and Nature themes
- **Prayer Moods**: Choose from Gratitude, Peace, Strength, Hope, or Forgiveness
- **Bible-style Prayers**: Curated prayers with matching Bible verses for each mood

### Gamification System
- **XP & Leveling**: Earn XP for each prayer, build your spiritual level
- **Level Titles**: Progress through titles like Seeker, Devoted, Faithful, Disciple, Apostle, Prophet, Saint
- **Achievements**: 18+ achievements to unlock across categories:
  - Streak achievements (3 days to 365 days)
  - Prayer count achievements (1 to 1000 prayers)
  - Time achievements (30 minutes to 10 hours)
  - Special achievements (Early Bird, Night Owl, Weekend Warrior)
- **Daily Challenges**: Fresh challenges every day with XP rewards
- **Prayer Streak**: Track consecutive days of prayer with animated flame
- **Confetti Celebrations**: Visual celebrations on prayer completion
- **Level Up Animations**: Special modal when reaching new levels

### Customization
- **6 Beautiful Themes**: Ocean, Sunset, Forest, Lavender, Midnight, Rose
- **4 Timer Styles**: Choose your preferred countdown visualization
- **Sound Options**: Gentle Chime, Meditation Bell, Nature Sounds, Soft Rain
- **Haptic Feedback**: Toggle vibration feedback
- **Celebration Effects**: Toggle confetti animations

### Additional Features
- **Daily Bible Verse**: New verse every day with share & copy
- **Statistics Dashboard**: Track your prayer journey with visual graphs
- **Mood History**: See which prayer moods you use most
- **Weekly Calendar**: Visual representation of your prayer activity
- **Beautiful Animations**: Smooth, calming animations throughout

## Screenshots

The app includes these beautifully designed screens:

1. **Animated Onboarding** - 5-page intro with floating shapes and progress indicators
2. **Home Dashboard** - Level badge, XP progress, streak flame, daily challenges
3. **Prayer Session** - Multiple timer styles with breathing guide
4. **Daily Verse** - Scripture with glow effects and sharing options
5. **Journey Stats** - Achievements, challenges, prayer history
6. **Settings** - Theme picker, timer customization, sound options

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Apple Developer account (for FamilyControls capability)

## Setup Instructions

### 1. Open in Xcode

```bash
# Clone the repository
git clone <your-repo-url>
cd PrayerLock

# Open in Xcode
open PrayerLock.xcodeproj
```

### 2. Configure Signing & Capabilities

1. Select the project in the Navigator
2. Select the "PrayerLock" target
3. Go to "Signing & Capabilities"
4. Set your **Development Team**
5. Change **Bundle Identifier** to something unique (e.g., `com.yourname.prayerlock`)
6. Ensure "Family Controls" capability is added

### 3. Preview in Xcode

You can preview individual views using SwiftUI Previews:

1. Open any view file (e.g., `Views/HomeView.swift`)
2. Press `Cmd + Option + P` or click "Resume" in the canvas
3. The preview will show the UI with sample data

### 4. Run on Device

**Important**: Screen Time APIs require a physical device.

1. Connect your iPhone (iOS 17+) to your Mac
2. Select your device in the toolbar
3. Press `Cmd + R` to build and run

## Project Structure

```
PrayerLock/
├── PrayerLock.xcodeproj
├── PrayerLock/
│   ├── PrayerLockApp.swift           # App entry point
│   ├── Info.plist                     # App configuration
│   ├── PrayerLock.entitlements        # Family Controls entitlement
│   │
│   ├── Views/
│   │   ├── ContentView.swift          # Main content router
│   │   ├── OnboardingView.swift       # Animated 5-page setup
│   │   ├── HomeView.swift             # Dashboard with gamification
│   │   ├── PrayerSessionView.swift    # Multi-style timer
│   │   ├── DailyVerseView.swift       # Bible verse with effects
│   │   ├── StatsView.swift            # Statistics & achievements
│   │   ├── SettingsView.swift         # Full customization
│   │   └── Components/
│   │       └── UIComponents.swift     # Reusable UI components
│   │
│   ├── Models/
│   │   ├── Prayer.swift               # Prayer & mood models
│   │   ├── BibleVerse.swift           # 31 daily verses
│   │   ├── UserSettings.swift         # Settings & streak
│   │   └── Gamification.swift         # Levels, XP, achievements
│   │
│   ├── ViewModels/
│   │   └── AppState.swift             # Global app state + gamification
│   │
│   ├── Services/
│   │   ├── ScreenTimeManager.swift    # Screen Time API wrapper
│   │   └── StorageManager.swift       # Local storage
│   │
│   └── Resources/
│       └── Assets.xcassets/           # Colors and app icon
│
└── PrayerLockShield/                   # Shield extension
    ├── ShieldConfigurationExtension.swift
    ├── Info.plist
    └── PrayerLockShield.entitlements
```

## Gamification Details

### XP System
- **25 XP** per completed prayer
- **10 XP** per streak day bonus
- **50 XP** bonus for first prayer
- Achievement unlocks award **50-5000 XP**

### Level Progression
| Level | Title | XP Required |
|-------|-------|-------------|
| 1 | Beginner | 0 |
| 2 | Seeker | 100 |
| 3 | Devoted | 250 |
| 4 | Faithful | 450 |
| 5 | Disciple | 700 |
| 6 | Apostle | 1000 |
| 7 | Prophet | 1350 |
| 8 | Saint | 1750 |
| 9 | Enlightened | 2200 |
| 10+ | Blessed | 2700+ |

### Daily Challenges
Three new challenges every day:
1. **Prayer Count**: Complete X prayers today
2. **Duration**: Spend X minutes in prayer
3. **Mood Focus**: Pray with a specific mood

## Customization

### Adding Themes
Edit `Models/Gamification.swift` to add new themes:

```swift
case newTheme = "New Theme"

var primaryColor: Color {
    case .newTheme: return Color(red: 0.5, green: 0.5, blue: 0.5)
}
```

### Adding Achievements
Edit `Models/Gamification.swift` to add new achievements:

```swift
Achievement(
    id: "unique_id",
    title: "Achievement Title",
    description: "How to unlock",
    icon: "sf.symbol.name",
    category: .special,
    requirement: 1,
    xpReward: 100,
    isUnlocked: false
)
```

### Adding Prayers
Edit `Models/Prayer.swift` to add new prayers for each mood.

## Troubleshooting

### "Family Controls not available"
- Run on a physical device, not the simulator
- Ensure your Apple Developer account has the Family Controls entitlement

### "Authorization denied"
- User must be signed into iCloud
- Screen Time must be enabled in device settings

### SwiftUI Previews not loading
- Clean build folder: `Cmd + Shift + K`
- Resume preview: `Cmd + Option + P`

## Privacy

This app:
- Stores all data locally on the device
- Does not collect or transmit any personal information
- Uses Screen Time APIs only for app blocking
- No analytics or tracking

## Tech Stack

- **SwiftUI** - Modern declarative UI
- **FamilyControls** - App selection
- **ManagedSettings** - App blocking/shielding
- **UserDefaults** - Local data persistence
- **Combine** - Reactive state management

## License

This project is for educational purposes. Feel free to use and modify.

## Acknowledgments

- Inspired by "Prayer Lock: Christian Focus" app
- UI/UX inspired by prayerlock.com
- Bible verses from various translations
- Built with SwiftUI and Apple's Screen Time APIs
