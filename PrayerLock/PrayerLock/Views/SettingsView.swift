import SwiftUI
import FamilyControls

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingAppPicker = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // Prayer Settings
                Section {
                    HStack {
                        Label("Prayer Duration", systemImage: "clock.fill")
                        Spacer()
                        Picker("", selection: Binding(
                            get: { appState.settings.prayerDurationSeconds },
                            set: { appState.updatePrayerDuration($0) }
                        )) {
                            Text("30 sec").tag(30)
                            Text("60 sec").tag(60)
                            Text("90 sec").tag(90)
                            Text("2 min").tag(120)
                            Text("5 min").tag(300)
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Label("Default Mood", systemImage: "heart.fill")
                        Spacer()
                        Picker("", selection: $appState.settings.selectedMood) {
                            ForEach(PrayerMood.allCases, id: \.self) { mood in
                                Text(mood.rawValue).tag(mood)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("Prayer")
                }
                
                // App Blocking
                Section {
                    HStack {
                        Label("Screen Time", systemImage: "hourglass")
                        Spacer()
                        
                        switch screenTimeManager.authorizationStatus {
                        case .authorized:
                            Text("Enabled")
                                .foregroundColor(.green)
                        case .denied:
                            Text("Denied")
                                .foregroundColor(.red)
                        case .notDetermined:
                            Button("Enable") {
                                Task {
                                    await screenTimeManager.requestAuthorization()
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showingAppPicker = true
                    }) {
                        HStack {
                            Label("Blocked Apps", systemImage: "apps.iphone")
                            Spacer()
                            Text("\(screenTimeManager.selectedAppCount) selected")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.selectedApps)
                    .onChange(of: screenTimeManager.selectedApps) { _, newValue in
                        screenTimeManager.saveSelection(newValue)
                    }
                    
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
                        Label("App Blocking Active", systemImage: "lock.fill")
                    }
                } header: {
                    Text("App Blocking")
                } footer: {
                    Text("When enabled, you'll need to pray before opening selected apps.")
                }
                
                // Stats
                Section {
                    HStack {
                        Label("Current Streak", systemImage: "flame.fill")
                        Spacer()
                        Text("\(appState.streak.currentStreak) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Longest Streak", systemImage: "trophy.fill")
                        Spacer()
                        Text("\(appState.streak.longestStreak) days")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Total Prayers", systemImage: "hands.clap.fill")
                        Spacer()
                        Text("\(appState.streak.totalPrayers)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Statistics")
                }
                
                // About
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Link(destination: URL(string: "mailto:support@prayerlock.app")!) {
                        HStack {
                            Label("Contact Support", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                } header: {
                    Text("About")
                }
                
                // Reset
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Reset All Data")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                } footer: {
                    Text("This will reset your streak, statistics, and all settings.")
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This action cannot be undone. Your prayer streak and all statistics will be lost.")
            }
        }
    }
    
    func resetAllData() {
        StorageManager.shared.clearAllData()
        appState.streak = PrayerStreak()
        appState.settings = UserSettings()
        screenTimeManager.disableBlocking()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
