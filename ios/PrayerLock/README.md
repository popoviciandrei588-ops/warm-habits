# PrayerLock (iOS 17+ SwiftUI)

This folder contains a SwiftUI iOS 17+ app that clones the core experience of “prayer lock: christian focus”:

- Pick distracting apps to block (Screen Time).
- Before scrolling, pause for a short prayer flow.
- After a prayer timer completes, the selected apps are unblocked.
- Subscription required for all features (StoreKit 2).

## Xcode project structure outline (recommended)

Create an Xcode workspace like this:

```
PrayerLock.xcworkspace
├─ PrayerLock.xcodeproj
│  ├─ PrayerLock (App target)
│  │  ├─ App/
│  │  │  ├─ PrayerLockApp.swift
│  │  │  ├─ RootView.swift
│  │  │  └─ AppContainer.swift
│  │  ├─ Core/
│  │  │  ├─ AppState.swift
│  │  │  ├─ FeatureGate.swift
│  │  │  └─ Logger.swift
│  │  ├─ Models/ (SwiftData @Model)
│  │  ├─ Persistence/
│  │  │  └─ ModelContainerFactory.swift
│  │  ├─ ScreenTime/
│  │  │  ├─ ScreenTimePermission.swift
│  │  │  ├─ AppBlockingManager.swift
│  │  │  └─ DeviceActivityManager.swift
│  │  ├─ Prayer/
│  │  │  ├─ Mood.swift
│  │  │  ├─ PrayerComposer.swift
│  │  │  └─ VerseProvider.swift
│  │  ├─ Store/
│  │  │  ├─ SubscriptionManager.swift
│  │  │  └─ PaywallView.swift
│  │  ├─ Features/
│  │  │  ├─ Onboarding/
│  │  │  ├─ PrayerFlow/
│  │  │  ├─ Stats/
│  │  │  ├─ Verse/
│  │  │  └─ Settings/
│  │  └─ UI/ (reusable components)
│  ├─ PrayerLockShieldExtension (ShieldConfiguration extension target)
│  └─ PrayerLockDeviceActivityMonitorExtension (DeviceActivityMonitor extension target)
└─ (optional) Shared swift packages
```

This repo includes the same structure under `ios/PrayerLock/Sources/...` to make it easy to copy into an Xcode project.

## Required entitlements + capabilities (Xcode)

To run real app blocking you must enable:

- **Family Controls** capability
- **App Groups** (recommended, to share state with extensions)
- **Managed Settings** (via Family Controls)
- **Device Activity** monitoring (for extension)

Also add `NSFamilyControlsUsageDescription` to Info.plist with a clear, faith-first explanation.

## Notes about “blocking until prayer completes”

iOS doesn’t let a third-party app intercept “open Instagram” in the same way as a system feature; what we can do is:

- Shield the user’s selected apps using `ManagedSettingsStore`.
- Show a shield UI (via shield extension) that directs them back into PrayerLock to complete the prayer timer.
- Only after the timer completes do we remove shielding.

This matches the “stop the scroll until prayer” core experience as closely as Apple’s Screen Time APIs allow.

