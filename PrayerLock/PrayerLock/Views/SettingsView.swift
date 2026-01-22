import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingAppPicker = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Theme Section
                        ThemeSection()
                        
                        // Timer Customization
                        TimerSection()
                        
                        // App Blocking
                        AppBlockingSection(showingAppPicker: $showingAppPicker)
                        
                        // Sound & Haptics
                        FeedbackSection()
                        
                        // Account Stats
                        AccountSection()
                        
                        // About & Reset
                        AboutSection(showingResetAlert: $showingResetAlert)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.selectedApps)
            .onChange(of: screenTimeManager.selectedApps) { _, newValue in
                screenTimeManager.saveSelection(newValue)
            }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    appState.resetAllData()
                    screenTimeManager.disableBlocking()
                }
            } message: {
                Text("This action cannot be undone. Your prayer streak, XP, achievements, and all statistics will be lost.")
            }
        }
    }
}

// MARK: - Theme Section
struct ThemeSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        SettingsCard(title: "Theme", icon: "paintbrush.fill") {
            VStack(spacing: 15) {
                // Theme grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemePreviewCard(
                            theme: theme,
                            isSelected: appState.settings.theme == theme
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                appState.setTheme(theme)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Timer Section
struct TimerSection: View {
    @EnvironmentObject var appState: AppState
    
    let durations = [30, 60, 90, 120, 180, 300]
    
    var body: some View {
        SettingsCard(title: "Prayer Timer", icon: "clock.fill") {
            VStack(spacing: 20) {
                // Duration
                VStack(alignment: .leading, spacing: 10) {
                    Text("Duration")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(durations, id: \.self) { duration in
                            DurationButton(
                                duration: duration,
                                isSelected: appState.settings.prayerDurationSeconds == duration
                            ) {
                                appState.updatePrayerDuration(duration)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Timer Style
                VStack(alignment: .leading, spacing: 10) {
                    Text("Timer Style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 10) {
                        ForEach(TimerStyle.allCases, id: \.self) { style in
                            TimerStyleButton(
                                style: style,
                                isSelected: appState.settings.timerStyle == style
                            ) {
                                appState.setTimerStyle(style)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Default Mood
                VStack(alignment: .leading, spacing: 10) {
                    Text("Default Mood")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(PrayerMood.allCases, id: \.self) { mood in
                                MoodChip(
                                    mood: mood,
                                    isSelected: appState.settings.selectedMood == mood
                                ) {
                                    appState.selectMood(mood)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct DurationButton: View {
    let duration: Int
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var label: String {
        if duration < 60 {
            return "\(duration)s"
        } else {
            let minutes = duration / 60
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? appState.settings.theme.gradient : LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
    }
}

struct TimerStyleButton: View {
    let style: TimerStyle
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.title2)
                Text(style.rawValue)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? appState.settings.theme.gradient : LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - App Blocking Section
struct AppBlockingSection: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @Binding var showingAppPicker: Bool
    
    var body: some View {
        SettingsCard(title: "App Blocking", icon: "lock.fill") {
            VStack(spacing: 15) {
                // Screen Time Status
                HStack {
                    VStack(alignment: .leading) {
                        Text("Screen Time")
                            .font(.subheadline)
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(statusColor)
                    }
                    
                    Spacer()
                    
                    if screenTimeManager.authorizationStatus != .authorized {
                        Button("Enable") {
                            Task {
                                await screenTimeManager.requestAuthorization()
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(appState.settings.theme.gradient)
                        .cornerRadius(20)
                    }
                }
                
                Divider()
                
                // Select Apps
                Button(action: { showingAppPicker = true }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Blocked Apps")
                                .font(.subheadline)
                            Text("\(screenTimeManager.selectedAppCount) apps selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Divider()
                
                // Blocking Toggle
                Toggle(isOn: Binding(
                    get: { screenTimeManager.isBlocking },
                    set: { newValue in
                        if newValue {
                            screenTimeManager.enableBlocking()
                        } else {
                            screenTimeManager.disableBlocking()
                        }
                    }
                )) {
                    VStack(alignment: .leading) {
                        Text("App Blocking")
                            .font(.subheadline)
                        Text("Require prayer before using selected apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .tint(appState.settings.theme.primaryColor)
            }
        }
    }
    
    var statusText: String {
        switch screenTimeManager.authorizationStatus {
        case .authorized: return "Enabled"
        case .denied: return "Access Denied"
        case .notDetermined: return "Not Configured"
        }
    }
    
    var statusColor: Color {
        switch screenTimeManager.authorizationStatus {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        }
    }
}

// MARK: - Feedback Section
struct FeedbackSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        SettingsCard(title: "Feedback", icon: "bell.fill") {
            VStack(spacing: 15) {
                // Haptics
                Toggle(isOn: $appState.settings.hapticsEnabled) {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundStyle(appState.settings.theme.gradient)
                            .frame(width: 24)
                        Text("Haptic Feedback")
                            .font(.subheadline)
                    }
                }
                .tint(appState.settings.theme.primaryColor)
                
                Divider()
                
                // Confetti
                Toggle(isOn: $appState.settings.showConfetti) {
                    HStack {
                        Image(systemName: "party.popper.fill")
                            .foregroundStyle(appState.settings.theme.gradient)
                            .frame(width: 24)
                        Text("Celebration Effects")
                            .font(.subheadline)
                    }
                }
                .tint(appState.settings.theme.primaryColor)
                
                Divider()
                
                // Sound
                HStack {
                    Image(systemName: appState.settings.prayerSound.icon)
                        .foregroundStyle(appState.settings.theme.gradient)
                        .frame(width: 24)
                    
                    Text("Prayer Sound")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Picker("", selection: $appState.settings.prayerSound) {
                        ForEach(PrayerSound.allCases, id: \.self) { sound in
                            Text(sound.rawValue).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(appState.settings.theme.primaryColor)
                }
            }
        }
    }
}

// MARK: - Account Section
struct AccountSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        SettingsCard(title: "Statistics", icon: "chart.bar.fill") {
            VStack(spacing: 12) {
                StatRow(label: "Level", value: "\(appState.currentLevel) (\(appState.levelTitle))")
                Divider()
                StatRow(label: "Total XP", value: "\(appState.settings.totalXP)")
                Divider()
                StatRow(label: "Current Streak", value: "\(appState.streak.currentStreak) days")
                Divider()
                StatRow(label: "Longest Streak", value: "\(appState.streak.longestStreak) days")
                Divider()
                StatRow(label: "Total Prayers", value: "\(appState.streak.totalPrayers)")
                Divider()
                StatRow(label: "Achievements Unlocked", value: "\(appState.achievements.filter { $0.isUnlocked }.count)/\(appState.achievements.count)")
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(appState.settings.theme.gradient)
        }
    }
}

// MARK: - About Section
struct AboutSection: View {
    @EnvironmentObject var appState: AppState
    @Binding var showingResetAlert: Bool
    
    var body: some View {
        SettingsCard(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 15) {
                HStack {
                    Text("Version")
                        .font(.subheadline)
                    Spacer()
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Divider()
                
                Link(destination: URL(string: "mailto:support@prayerlock.app")!) {
                    HStack {
                        Text("Contact Support")
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
                
                Divider()
                
                Button(action: { showingResetAlert = true }) {
                    HStack {
                        Text("Reset All Data")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Settings Card
struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    @EnvironmentObject var appState: AppState
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(appState.settings.theme.gradient)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
