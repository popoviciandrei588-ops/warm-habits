# Prayer Lock 🙏

A faith-first screen-time blocker for iOS 17+. Before opening distracting apps, users complete a calming 60-second prayer flow. Built with SwiftUI, FamilyControls, ManagedSettings, and StoreKit 2.

> "Your phone is taking you away from God. Unlock prayer, unlock peace."

## 📱 Screenshots

The app features a premium, minimal, calming design with:
- Immersive gradient backgrounds with floating orbs
- Smooth micro-animations throughout
- Typography-first layouts
- Glass morphism effects

---

## 🗺️ Screen Map & Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP LAUNCH                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │     hasCompletedOnboarding?   │
              └───────────────────────────────┘
                     │              │
                    NO             YES
                     │              │
                     ▼              ▼
        ┌─────────────────┐   ┌─────────────────┐
        │   ONBOARDING    │   │   MAIN TAB      │
        │                 │   │                 │
        │ • Page 1: Hook  │   │ ┌─────┬─────┐  │
        │ • Page 2: Value │   │ │Home │Stats│  │
        │ • Page 3: Perms │   │ ├─────┼─────┤  │
        │ • App Picker    │   │ │Verse│Setts│  │
        └─────────────────┘   │ └─────┴─────┘  │
                │              └─────────────────┘
                │                     │
                └──────────┬──────────┘
                           │
                           ▼
                ┌─────────────────────┐
                │     HOME VIEW       │
                │                     │
                │ • Streak badge      │
                │ • Quick stats       │
                │ • Start Prayer CTA  │
                │ • Verse preview     │
                │ • Blocking status   │
                └─────────────────────┘
                           │
                    [Start Prayer]
                           │
                           ▼
        ┌─────────────────────────────────────────┐
        │              PRAYER FLOW                 │
        │  (Full-screen modal)                    │
        │                                         │
        │  Step 1: Mood Selection                 │
        │  ┌─────────────────────────────────┐   │
        │  │ "How are you feeling?"          │   │
        │  │ [Anxious] [Grateful] [Tempted]  │   │
        │  │ [Distracted] [Lonely] [Angry]   │   │
        │  │ [Peaceful] [Tired]              │   │
        │  │ + Optional text note            │   │
        │  └─────────────────────────────────┘   │
        │                  │                      │
        │                  ▼                      │
        │  Step 2: Prayer Display                 │
        │  ┌─────────────────────────────────┐   │
        │  │ Generated prayer based on mood  │   │
        │  │ Serif typography, centered      │   │
        │  │ [Begin Timer]                   │   │
        │  └─────────────────────────────────┘   │
        │                  │                      │
        │                  ▼                      │
        │  Step 3: Timer (60 seconds)             │
        │  ┌─────────────────────────────────┐   │
        │  │      ╭───────────────╮          │   │
        │  │     ╱   0:45          ╲         │   │
        │  │    │   Breathe deeply  │        │   │
        │  │     ╲                 ╱         │   │
        │  │      ╰───────────────╯          │   │
        │  │   (breathing animation)         │   │
        │  └─────────────────────────────────┘   │
        │                  │                      │
        │                  ▼                      │
        │  Step 4: Completion                     │
        │  ┌─────────────────────────────────┐   │
        │  │         ✓ Prayer Complete       │   │
        │  │  Apps unlocked for 10 minutes   │   │
        │  │           [Done]                │   │
        │  └─────────────────────────────────┘   │
        └─────────────────────────────────────────┘
```

### Tab Navigation

| Tab | View | Purpose |
|-----|------|---------|
| 🏠 Home | `HomeView` | Dashboard with streak, stats, main CTA |
| 📊 Stats | `StatsView` | Detailed analytics and mood patterns |
| 📖 Verse | `VerseView` | Premium verse of the day display |
| ⚙️ Settings | `SettingsView` | Configuration and subscription |

---

## 🎨 Design System

### Color Palette

```swift
// Primary Brand Colors
Primary:        #1E3A5F  (Deep spiritual blue)
Accent:         #3B82F6  (Bright blue)
Secondary:      #8B5CF6  (Purple)

// Gradients
Background:     #0F172A → #1E3A5F → #1E40AF
Timer Ring:     #3B82F6 → #8B5CF6 → #EC4899

// Semantic Colors
Success:        #10B981
Warning:        #F59E0B
Error:          #EF4444

// Mood Colors
Anxious:        #F59E0B
Grateful:       #10B981
Tempted:        #EF4444
Distracted:     #8B5CF6
Lonely:         #6366F1
Angry:          #DC2626
Peaceful:       #0EA5E9
Tired:          #64748B
```

### Typography Scale

```swift
// Display (Hero headlines)
displayLarge:   48pt, Bold, Rounded
displayMedium:  40pt, Bold, Rounded
displaySmall:   32pt, Bold, Rounded

// Headlines
headlineLarge:  28pt, Semibold, Rounded
headlineMedium: 24pt, Semibold, Rounded
headlineSmall:  20pt, Semibold, Rounded

// Titles
titleLarge:     18pt, Semibold, Rounded
titleMedium:    16pt, Semibold, Rounded
titleSmall:     14pt, Semibold, Rounded

// Body
bodyLarge:      17pt, Regular, Default
bodyMedium:     15pt, Regular, Default
bodySmall:      13pt, Regular, Default

// Labels
labelLarge:     14pt, Medium, Default
labelMedium:    12pt, Medium, Default
labelSmall:     10pt, Medium, Default

// Special
timerDisplay:   72pt, Light, Rounded
verseText:      24pt, Light, Serif
verseReference: 14pt, Medium, Serif
```

### Spacing System

```swift
xxxs:   2pt
xxs:    4pt
xs:     8pt
sm:     12pt
md:     16pt
lg:     24pt
xl:     32pt
xxl:    48pt
xxxl:   64pt
```

### Border Radius

```swift
sm:     8pt
md:     12pt
lg:     16pt
xl:     24pt
full:   9999pt
```

### Component Library

| Component | Description |
|-----------|-------------|
| `MoodChip` | Selectable mood pill with icon and color |
| `TimerRing` | Animated circular progress with breathing effect |
| `StreakBadge` | Fire icon with streak count |
| `StatCard` | Stat display with icon and value |
| `GlassCard` | Frosted glass container |
| `AnimatedBackground` | Gradient with floating orbs |

### Button Styles

- **Primary**: Gradient fill, white text, full-width
- **Secondary**: Tinted background, accent text
- **Ghost**: Text only, subtle tap state

---

## 📁 Project Structure

```
PrayerLock/
├── PrayerLock/
│   ├── App/
│   │   ├── PrayerLockApp.swift      # App entry point
│   │   ├── AppState.swift           # Global app state
│   │   ├── DesignSystem.swift       # Colors, typography, components
│   │   └── RootView.swift           # Root navigation controller
│   │
│   ├── Models/
│   │   ├── PrayerSession.swift      # SwiftData model for sessions
│   │   ├── DailyStreak.swift        # SwiftData model for streaks
│   │   ├── UserSettings.swift       # SwiftData model for settings
│   │   └── Verse.swift              # Verse data model
│   │
│   ├── Managers/
│   │   ├── BlockingManager.swift    # FamilyControls + ManagedSettings
│   │   ├── SubscriptionManager.swift # StoreKit 2 subscriptions
│   │   └── StatsManager.swift       # Statistics calculations
│   │
│   ├── Services/
│   │   └── PrayerService.swift      # Prayer generation templates
│   │
│   ├── Views/
│   │   ├── MainTabView.swift        # Tab bar container
│   │   ├── HomeView.swift           # Dashboard
│   │   │
│   │   ├── Onboarding/
│   │   │   └── OnboardingView.swift # 3-page onboarding flow
│   │   │
│   │   ├── Prayer/
│   │   │   ├── PrayerFlowView.swift     # Prayer flow container
│   │   │   ├── MoodSelectionView.swift  # Mood picker
│   │   │   ├── PrayerDisplayView.swift  # Generated prayer
│   │   │   └── CompletionView.swift     # Success screen
│   │   │
│   │   ├── Timer/
│   │   │   └── TimerView.swift      # 60-second countdown
│   │   │
│   │   ├── Stats/
│   │   │   └── StatsView.swift      # Analytics dashboard
│   │   │
│   │   ├── Verse/
│   │   │   └── VerseView.swift      # Verse of the day
│   │   │
│   │   ├── Settings/
│   │   │   └── SettingsView.swift   # App configuration
│   │   │
│   │   ├── Paywall/
│   │   │   └── PaywallView.swift    # Subscription paywall
│   │   │
│   │   └── Components/
│   │       ├── MoodChip.swift
│   │       ├── TimerRing.swift
│   │       ├── StreakBadge.swift
│   │       ├── StatCard.swift
│   │       ├── GlassCard.swift
│   │       └── AnimatedBackground.swift
│   │
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── Info.plist
│       └── PrayerLock.entitlements
│
├── PrayerLockShield/                # Shield Configuration Extension
│   ├── ShieldConfigurationExtension.swift
│   └── Info.plist
│
├── PrayerLockMonitor/               # Device Activity Monitor Extension
│   ├── DeviceActivityMonitorExtension.swift
│   └── Info.plist
│
└── PrayerLockAction/                # Shield Action Extension
    ├── ShieldActionExtension.swift
    └── Info.plist
```

---

## 🚀 Setup Instructions

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ device (Screen Time APIs don't work in simulator)
- Apple Developer Account with Family Controls capability

### 1. Configure Capabilities

1. Open `PrayerLock.xcodeproj` in Xcode
2. Select the PrayerLock target
3. Go to **Signing & Capabilities**
4. Add:
   - **Family Controls**
   - **App Groups** (`group.com.prayerlock.shared`)

### 2. Configure Extensions

For each extension (Shield, Monitor, Action):
1. Add the extension target
2. Enable **Family Controls** capability
3. Add the same **App Group**

### 3. Configure StoreKit

1. Create products in App Store Connect:
   - `com.prayerlock.monthly` - Monthly subscription
   - `com.prayerlock.yearly` - Yearly subscription
   - `com.prayerlock.lifetime` - Lifetime purchase

2. For testing, create a StoreKit Configuration file in Xcode

### 4. Run on Device

```bash
# Screen Time APIs require a physical device
# Select your device and run from Xcode
```

---

## 🔐 API Overview

### FamilyControls

```swift
// Request authorization
let center = AuthorizationCenter.shared
try await center.requestAuthorization(for: .individual)

// App selection
@FamilyActivityPicker var selection: FamilyActivitySelection
```

### ManagedSettings

```swift
// Apply shield to apps
let store = ManagedSettingsStore()
store.shield.applications = selection.applicationTokens
store.shield.applicationCategories = .specific(selection.categoryTokens)
```

### DeviceActivity

```swift
// Schedule blocking periods
let center = DeviceActivityCenter()
try center.startMonitoring(.dailyBlocking, during: schedule)
```

### StoreKit 2

```swift
// Load products
let products = try await Product.products(for: productIDs)

// Purchase
let result = try await product.purchase()

// Check entitlements
for await result in Transaction.currentEntitlements {
    // Handle active subscriptions
}
```

---

## 🎯 Key Features

### ✅ App Blocking
- FamilyControls for app selection
- ManagedSettings for shield enforcement
- Custom shield UI with Prayer Lock branding
- Configurable unlock window (5-60 minutes)

### ✅ Prayer Flow
- 8 mood options with custom icons
- Template-based prayer generation
- 60-second (configurable) meditation timer
- Breathing animation with haptic feedback

### ✅ Streak & Stats
- Daily streak tracking
- Total minutes prayed
- Session count
- Mood distribution over time
- Weekly activity chart

### ✅ Verse of the Day
- Premium typography layout
- Subtle parallax scrolling
- Share functionality
- 15+ curated verses

### ✅ Subscription Paywall
- StoreKit 2 integration
- Monthly, yearly, lifetime options
- Restore purchases
- Feature gating

---

## 📝 License

MIT License - See LICENSE file for details.

---

## 🙌 Credits

Built with love and prayer. 

Inspired by [prayerlock.com](https://prayerlock.com) - "Unlock prayer, unlock peace."
