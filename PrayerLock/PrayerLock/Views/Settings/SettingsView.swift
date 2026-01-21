import SwiftUI
import SwiftData

/// Settings view for the app
struct SettingsView: View {
    @Query private var settings: [UserSettings]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var showAppSelection = false
    @State private var showPaywall = false
    @State private var showDurationPicker = false
    
    private var userSettings: UserSettings {
        settings.first ?? createDefaultSettings()
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Subscription section
                subscriptionSection
                
                // Prayer settings
                prayerSettingsSection
                
                // App blocking settings
                blockingSettingsSection
                
                // Permissions
                permissionsSection
                
                // Support
                supportSection
                
                // About
                aboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAppSelection) {
                AppSelectionView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showDurationPicker) {
                DurationPickerView(currentDuration: userSettings.prayerDurationSeconds) { newDuration in
                    updateDuration(newDuration)
                }
            }
        }
    }
    
    // MARK: - Subscription Section
    private var subscriptionSection: some View {
        Section {
            if subscriptionManager.hasPremiumAccess {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading) {
                        Text("Premium Active")
                            .font(.headline)
                        Text("Thank you for supporting Prayer Lock!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Button(action: { showPaywall = true }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading) {
                            Text("Unlock Premium")
                                .font(.headline)
                            Text("Get full access to all features")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Subscription")
        }
    }
    
    // MARK: - Prayer Settings Section
    private var prayerSettingsSection: some View {
        Section {
            // Prayer duration
            Button(action: { showDurationPicker = true }) {
                HStack {
                    Label("Prayer Duration", systemImage: "timer")
                    
                    Spacer()
                    
                    Text(userSettings.formattedDuration)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            // Haptic feedback toggle
            Toggle(isOn: Binding(
                get: { userSettings.hapticFeedbackEnabled },
                set: { newValue in
                    userSettings.hapticFeedbackEnabled = newValue
                }
            )) {
                Label("Haptic Feedback", systemImage: "waveform")
            }
        } header: {
            Text("Prayer Settings")
        } footer: {
            Text("Prayer duration applies to your next prayer session")
        }
    }
    
    // MARK: - Blocking Settings Section
    private var blockingSettingsSection: some View {
        Section {
            Button(action: { showAppSelection = true }) {
                HStack {
                    Label("Blocked Apps", systemImage: "app.badge")
                    
                    Spacer()
                    
                    Text("\(screenTimeManager.selectedCount) selected")
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            // Current blocking status
            HStack {
                Label("Blocking Status", systemImage: screenTimeManager.isBlocking ? "lock.fill" : "lock.open")
                
                Spacer()
                
                Text(screenTimeManager.isBlocking ? "Active" : "Inactive")
                    .foregroundColor(screenTimeManager.isBlocking ? .orange : .green)
            }
        } header: {
            Text("App Blocking")
        }
    }
    
    // MARK: - Permissions Section
    private var permissionsSection: some View {
        Section {
            HStack {
                Label("Screen Time", systemImage: "hourglass")
                
                Spacer()
                
                if screenTimeManager.authorizationStatus.isAuthorized {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Granted")
                            .foregroundColor(.green)
                    }
                } else {
                    Button("Grant Access") {
                        Task {
                            await screenTimeManager.requestAuthorization()
                        }
                    }
                    .foregroundColor(.indigo)
                }
            }
        } header: {
            Text("Permissions")
        } footer: {
            Text("Screen Time permission is required to block apps")
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        Section {
            Button(action: { subscriptionManager.restorePurchases() as Void }) {
                Label("Restore Purchases", systemImage: "arrow.counterclockwise")
            }
            
            Link(destination: URL(string: "mailto:support@prayerlock.app")!) {
                Label("Contact Support", systemImage: "envelope")
            }
            
            Link(destination: URL(string: "https://prayerlock.app/faq")!) {
                Label("FAQ", systemImage: "questionmark.circle")
            }
        } header: {
            Text("Support")
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        Section {
            Link(destination: URL(string: "https://prayerlock.app/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
            
            Link(destination: URL(string: "https://prayerlock.app/terms")!) {
                Label("Terms of Service", systemImage: "doc.text")
            }
            
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("About")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createDefaultSettings() -> UserSettings {
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        return newSettings
    }
    
    private func updateDuration(_ duration: Int) {
        userSettings.prayerDurationSeconds = duration
    }
}

// MARK: - Duration Picker View
struct DurationPickerView: View {
    let currentDuration: Int
    let onSelect: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDuration: Int
    @State private var customMinutes: Int = 1
    @State private var customSeconds: Int = 0
    @State private var isCustom = false
    
    private let presetDurations = [30, 60, 90, 120, 180, 300]
    
    init(currentDuration: Int, onSelect: @escaping (Int) -> Void) {
        self.currentDuration = currentDuration
        self.onSelect = onSelect
        _selectedDuration = State(initialValue: currentDuration)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(presetDurations, id: \.self) { duration in
                        Button(action: {
                            selectedDuration = duration
                            isCustom = false
                        }) {
                            HStack {
                                Text(formatDuration(duration))
                                
                                Spacer()
                                
                                if selectedDuration == duration && !isCustom {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.indigo)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    Text("Preset Durations")
                }
                
                Section {
                    Toggle("Use Custom Duration", isOn: $isCustom)
                    
                    if isCustom {
                        Stepper("Minutes: \(customMinutes)", value: $customMinutes, in: 0...10)
                        Stepper("Seconds: \(customSeconds)", value: $customSeconds, in: 0...59, step: 15)
                    }
                } header: {
                    Text("Custom")
                }
            }
            .navigationTitle("Prayer Duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let finalDuration = isCustom ? (customMinutes * 60 + customSeconds) : selectedDuration
                        onSelect(max(15, finalDuration)) // Minimum 15 seconds
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let secs = seconds % 60
            if secs == 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s")"
            }
            return "\(minutes)m \(secs)s"
        }
        return "\(seconds) seconds"
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
