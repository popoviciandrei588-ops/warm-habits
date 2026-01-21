# Prayer Lock - iOS App

A faith-first screen time blocker where selected distracting apps are blocked until the user completes a short, Bible-rooted prayer flow.

**"Before Instagram, TikTok, or games open, you pause, pray, and then unlock."**

## Features

### Core Features
- **App Blocking**: Stop the scroll and create space for prayer using Apple's Screen Time APIs
- **Personalized Prayers**: Prayers matched to your mood/feeling, rooted in Biblical themes
- **Prayer Streak Tracking**: Build consistent prayer habits with streak tracking
- **Prayer Journey Analytics**: Track total prayers, time spent, moods, and more
- **Daily Bible Verse**: Beautiful scripture display to inspire your day

### User Flow
1. **Onboarding**: Explain the concept and request Screen Time permissions
2. **App Selection**: Choose which apps to block (using FamilyControls picker)
3. **Mood Selection**: "Tell God how you feel today" - select your current emotion
4. **Prayer Timer**: 60-second (configurable) prayer countdown with personalized prayer text
5. **Unlock**: Apps are unblocked after completing the prayer

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Project Structure

```
PrayerLock/
├── PrayerLock.xcodeproj/
├── PrayerLock/
│   ├── App/
│   │   ├── PrayerLockApp.swift          # Main app entry point
│   │   └── ContentView.swift             # Root navigation
│   ├── Models/
│   │   ├── UserSettings.swift            # User preferences (SwiftData)
│   │   ├── BlockSelection.swift          # App blocking selection
│   │   ├── PrayerSession.swift           # Prayer session records
│   │   ├── Streak.swift                  # Streak tracking
│   │   └── VerseOfDay.swift              # Bible verse storage
│   ├── Views/
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift      # Initial setup flow
│   │   ├── AppSelection/
│   │   │   └── AppSelectionView.swift    # FamilyControls picker
│   │   ├── Mood/
│   │   │   └── MoodSelectionView.swift   # Mood/feeling selection
│   │   ├── Prayer/
│   │   │   ├── PrayerTimerView.swift     # Main prayer lock screen
│   │   │   └── PrayerCompletedView.swift # Completion celebration
│   │   ├── Stats/
│   │   │   └── StatsView.swift           # Prayer journey analytics
│   │   ├── Verse/
│   │   │   └── VerseView.swift           # Daily verse display
│   │   ├── Settings/
│   │   │   └── SettingsView.swift        # App settings
│   │   └── Paywall/
│   │       └── PaywallView.swift         # Subscription purchase
│   ├── Managers/
│   │   ├── ScreenTimeManager.swift       # FamilyControls + ManagedSettings
│   │   ├── SubscriptionManager.swift     # StoreKit 2 subscriptions
│   │   └── DeviceActivityMonitorExtension.swift
│   ├── Services/
│   │   └── PrayerComposer.swift          # Prayer generation
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── Color+Extensions.swift
│   └── Resources/
│       └── Assets.xcassets/
```

## Technical Implementation

### Screen Time APIs

The app uses three Apple Screen Time frameworks:

1. **FamilyControls**: For app selection picker
   - `AuthorizationCenter` for permission requests
   - `FamilyActivitySelection` for storing selections

2. **ManagedSettings**: For app shielding (blocking)
   - `ManagedSettingsStore` for applying shields
   - `ShieldSettings` for configuring blocked app UI

3. **DeviceActivity**: For monitoring and scheduling
   - `DeviceActivityCenter` for session monitoring
   - `DeviceActivityMonitor` for event handling

### SwiftData Models

- **UserSettings**: App preferences, subscription status, onboarding completion
- **BlockSelection**: Stored app/category selections with serialized tokens
- **PrayerSession**: Individual prayer records with mood, duration, completion status
- **Streak**: Current/longest streak, total stats, mood breakdown
- **VerseOfDay**: Saved and favorited Bible verses

### Prayer Generation

The `PrayerComposer` service generates personalized prayers:
- 16 mood categories with multiple templates each
- Bible references matched to emotions
- Support for custom user input
- Stubbed remote API integration point for future AI-generated prayers

### StoreKit 2 Subscriptions

- Weekly, Monthly, Yearly subscription options
- Lifetime purchase option
- Automatic transaction listening
- Restore purchases support
- Mock products for development/testing

## Settings

### Configurable Options
- Prayer duration (30s, 60s, 90s, 120s, 3min, 5min, or custom)
- Haptic feedback toggle
- App blocking selection
- Subscription management

## Getting Started

### 1. Clone and Open
```bash
git clone <repository>
cd PrayerLock
open PrayerLock.xcodeproj
```

### 2. Configure Capabilities
In Xcode, add the following capabilities:
- Family Controls
- App Groups (optional, for extensions)

### 3. Configure Entitlements
The `PrayerLock.entitlements` file includes:
```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

### 4. Set Up StoreKit Testing
1. Create a StoreKit Configuration file in Xcode
2. Add products matching `SubscriptionManager.ProductID`
3. Enable StoreKit testing in scheme

### 5. Build and Run
- Select your device or simulator
- Build and run (⌘R)

## Important Notes

### Screen Time Permissions
- Requires physical device for full testing
- Simulator has limited Screen Time API support
- User must grant Family Controls permission

### App Review Guidelines
When submitting to App Store:
- Clearly explain Screen Time usage
- Provide privacy policy
- Include subscription terms
- Test all purchase flows

### Edge Cases Handled
- User exits during prayer → Shield remains until new prayer completed
- Missing permissions → Guided fix screen shown
- Duration changes → Applied to next session
- Multiple apps → All unblocked after completion

## Moods Supported

| Positive | Challenging |
|----------|-------------|
| Grateful | Anxious |
| Joyful | Sad |
| Hopeful | Stressed |
| Peaceful | Frustrated |
| Thankful | Overwhelmed |
| Content | Lonely |
| Excited | Fearful |
| | Angry |
| | Confused |

## License

This project is for educational and demonstration purposes.

## Support

For questions or issues, contact: support@prayerlock.app
