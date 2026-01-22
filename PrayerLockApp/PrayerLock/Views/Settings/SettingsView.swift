import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var blockingManager: BlockingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var showAppPicker = false
    @State private var showManageSubscription = false
    
    var body: some View {
        NavigationStack {
            List {
                // Prayer Settings
                Section {
                    // Duration picker
                    NavigationLink {
                        DurationPickerView(duration: $appState.prayerDuration)
                    } label: {
                        HStack {
                            SettingsIcon(icon: "timer", color: Color(hex: "3B82F6"))
                            VStack(alignment: .leading) {
                                Text("Prayer Duration")
                                Text("\(appState.prayerDuration) seconds")
                                    .font(PLTypography.bodySmall)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Unlock window
                    NavigationLink {
                        UnlockWindowPickerView(window: $appState.unlockWindow)
                    } label: {
                        HStack {
                            SettingsIcon(icon: "lock.open", color: Color(hex: "10B981"))
                            VStack(alignment: .leading) {
                                Text("Unlock Window")
                                Text("\(appState.unlockWindow) minutes")
                                    .font(PLTypography.bodySmall)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Prayer")
                }
                
                // Blocking Settings
                Section {
                    Button {
                        showAppPicker = true
                    } label: {
                        HStack {
                            SettingsIcon(icon: "apps.iphone", color: Color(hex: "8B5CF6"))
                            VStack(alignment: .leading) {
                                Text("Blocked Apps")
                                    .foregroundColor(.primary)
                                Text("\(blockingManager.selectedAppsCount) apps selected")
                                    .font(PLTypography.bodySmall)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle(isOn: Binding(
                        get: { blockingManager.isBlocking },
                        set: { newValue in
                            if newValue {
                                blockingManager.startBlocking()
                            } else {
                                blockingManager.stopBlocking()
                            }
                        }
                    )) {
                        HStack {
                            SettingsIcon(icon: "shield.fill", color: Color(hex: "EF4444"))
                            Text("Blocking Active")
                        }
                    }
                    .tint(Color(hex: "10B981"))
                } header: {
                    Text("App Blocking")
                }
                
                // Reminders
                Section {
                    Toggle(isOn: $appState.dailyReminderEnabled) {
                        HStack {
                            SettingsIcon(icon: "bell.fill", color: Color(hex: "F59E0B"))
                            Text("Daily Reminder")
                        }
                    }
                    .tint(Color(hex: "10B981"))
                    
                    if appState.dailyReminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: {
                                    Date(timeIntervalSince1970: appState.dailyReminderTime)
                                },
                                set: {
                                    appState.dailyReminderTime = $0.timeIntervalSince1970
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Reminders")
                }
                
                // Appearance
                Section {
                    Toggle(isOn: $appState.isDarkMode) {
                        HStack {
                            SettingsIcon(icon: "moon.fill", color: Color(hex: "6366F1"))
                            Text("Dark Mode")
                        }
                    }
                    .tint(Color(hex: "10B981"))
                } header: {
                    Text("Appearance")
                }
                
                // Subscription
                Section {
                    Button {
                        appState.showPaywall = true
                    } label: {
                        HStack {
                            SettingsIcon(icon: "crown.fill", color: Color(hex: "F59E0B"))
                            VStack(alignment: .leading) {
                                Text("Subscription")
                                    .foregroundColor(.primary)
                                Text(subscriptionManager.hasActiveSubscription ? "Active" : "Not subscribed")
                                    .font(PLTypography.bodySmall)
                                    .foregroundColor(subscriptionManager.hasActiveSubscription ? Color(hex: "10B981") : .secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "arrow.clockwise", color: Color(hex: "64748B"))
                            Text("Restore Purchases")
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // About
                Section {
                    Link(destination: URL(string: "https://prayerlock.com/privacy")!) {
                        HStack {
                            SettingsIcon(icon: "hand.raised.fill", color: Color(hex: "64748B"))
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://prayerlock.com/terms")!) {
                        HStack {
                            SettingsIcon(icon: "doc.text.fill", color: Color(hex: "64748B"))
                            Text("Terms of Service")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        SettingsIcon(icon: "info.circle.fill", color: Color(hex: "64748B"))
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $blockingManager.selectedApps
            )
            .onChange(of: blockingManager.selectedApps) { _, _ in
                blockingManager.updateSelectedApps(blockingManager.selectedApps)
            }
        }
    }
}

// MARK: - Settings Icon
struct SettingsIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Duration Picker View
struct DurationPickerView: View {
    @Binding var duration: Int
    @Environment(\.dismiss) private var dismiss
    
    private let durations = [30, 45, 60, 90, 120, 180]
    
    var body: some View {
        List {
            ForEach(durations, id: \.self) { seconds in
                Button {
                    duration = seconds
                    dismiss()
                } label: {
                    HStack {
                        Text(formatDuration(seconds))
                            .foregroundColor(.primary)
                        Spacer()
                        if duration == seconds {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "3B82F6"))
                        }
                    }
                }
            }
        }
        .navigationTitle("Prayer Duration")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds) seconds"
        } else {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
    }
}

// MARK: - Unlock Window Picker View
struct UnlockWindowPickerView: View {
    @Binding var window: Int
    @Environment(\.dismiss) private var dismiss
    
    private let windows = [5, 10, 15, 20, 30, 45, 60]
    
    var body: some View {
        List {
            ForEach(windows, id: \.self) { minutes in
                Button {
                    window = minutes
                    dismiss()
                } label: {
                    HStack {
                        Text("\(minutes) minutes")
                            .foregroundColor(.primary)
                        Spacer()
                        if window == minutes {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color(hex: "3B82F6"))
                        }
                    }
                }
            }
        }
        .navigationTitle("Unlock Window")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(BlockingManager())
        .environmentObject(SubscriptionManager())
}
