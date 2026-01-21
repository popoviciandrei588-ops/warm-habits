import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var userSettings: [UserSettings]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if let settings = userSettings.first, settings.isOnboardingCompleted {
                MainView()
            } else {
                OnboardingView(isOnboardingCompleted: Binding(
                    get: { userSettings.first?.isOnboardingCompleted ?? false },
                    set: { newValue in
                        if let settings = userSettings.first {
                            settings.isOnboardingCompleted = newValue
                        } else {
                            let newSettings = UserSettings(isOnboardingCompleted: newValue)
                            modelContext.insert(newSettings)
                        }
                    }
                ))
            }
        }
        .onAppear {
            if userSettings.isEmpty {
                // Initialize default settings
                 // Managed by Onboarding check usually, but for SwiftData query to work we might need to insert if empty?
                 // Actually @Query returns empty array if nothing there.
            }
        }
    }
}

struct MainView: View {
    @State private var currentStep: FlowStep = .mood
    @State private var selectedPrayer: PrayerTemplate?
    @State private var showPaywall = false
    
    enum FlowStep {
        case mood
        case prayer
        case unlocked
    }
    
    var body: some View {
        TabView {
            // Home Tab
            VStack {
                switch currentStep {
                case .mood:
                    MoodSelectionView { mood in
                        // Generate prayer and move to next step
                        // Check subscription first
                        if !StoreKitManager.shared.hasActiveSubscription {
                             showPaywall = true
                        } else {
                            self.selectedPrayer = PrayerComposer.shared.generatePrayer(for: mood)
                            self.currentStep = .prayer
                        }
                    }
                case .prayer:
                    if let prayer = selectedPrayer {
                        PrayerTimerView(prayer: prayer, duration: 60) {
                            self.currentStep = .unlocked
                        }
                    }
                case .unlocked:
                    UnlockedView {
                        self.currentStep = .mood
                    }
                }
            }
            .tabItem {
                Label("Pray", systemImage: "hands.sparkles.fill")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall)
            }
            
            // Stats Tab
            StatsView()
                .tabItem {
                    Label("Journey", systemImage: "chart.bar.fill")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct StatsView: View {
    @Query(sort: \PrayerSession.date, order: .reverse) var sessions: [PrayerSession]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Summary")) {
                    HStack {
                        Text("Total Sessions")
                        Spacer()
                        Text("\(sessions.count)")
                    }
                    HStack {
                        Text("Time Prayed")
                        Spacer()
                        Text("\(sessions.reduce(0) { $0 + $1.durationSeconds } / 60) mins")
                    }
                }
                
                Section(header: Text("History")) {
                    ForEach(sessions) { session in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.mood)
                                    .font(.headline)
                                Text(session.date, style: .date)
                                    .font(.caption)
                            }
                            Spacer()
                            Text("\(session.durationSeconds)s")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Your Journey")
        }
    }
}
