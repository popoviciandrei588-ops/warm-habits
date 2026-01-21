import SwiftUI
import SwiftData

/// Root content view that manages the app's navigation state
struct ContentView: View {
    @Query private var settings: [UserSettings]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var hasCompletedOnboarding = false
    @State private var showPaywall = false
    
    private var userSettings: UserSettings? {
        settings.first
    }
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding && userSettings?.hasCompletedOnboarding != true {
                // Show onboarding for new users
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .onChange(of: hasCompletedOnboarding) { _, newValue in
                        if newValue {
                            saveOnboardingComplete()
                        }
                    }
            } else if !subscriptionManager.hasPremiumAccess {
                // Show paywall if not subscribed
                PaywallView()
            } else {
                // Main app
                MainTabView()
            }
        }
        .onAppear {
            initializeSettingsIfNeeded()
            checkOnboardingStatus()
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeSettingsIfNeeded() {
        if settings.isEmpty {
            let newSettings = UserSettings()
            modelContext.insert(newSettings)
        }
        
        // Also ensure we have a streak object
        initializeStreakIfNeeded()
    }
    
    private func initializeStreakIfNeeded() {
        let descriptor = FetchDescriptor<Streak>()
        let streaks = (try? modelContext.fetch(descriptor)) ?? []
        
        if streaks.isEmpty {
            let newStreak = Streak()
            modelContext.insert(newStreak)
        } else {
            // Check streak validity when app opens
            streaks.first?.checkStreakValidity()
        }
    }
    
    private func checkOnboardingStatus() {
        if let settings = userSettings {
            hasCompletedOnboarding = settings.hasCompletedOnboarding
        }
    }
    
    private func saveOnboardingComplete() {
        if let settings = userSettings {
            settings.hasCompletedOnboarding = true
        } else {
            let newSettings = UserSettings(hasCompletedOnboarding: true)
            modelContext.insert(newSettings)
        }
        
        try? modelContext.save()
    }
}

/// Main tab-based navigation view
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Pray", systemImage: "hands.sparkles.fill")
                }
                .tag(0)
            
            StatsView()
                .tabItem {
                    Label("Journey", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            VerseView()
                .tabItem {
                    Label("Verse", systemImage: "book.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.indigo)
    }
}

/// Home view - the main prayer initiation screen
struct HomeView: View {
    @Query private var settings: [UserSettings]
    @Query private var streaks: [Streak]
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    
    @State private var showMoodSelection = false
    @State private var showAppSelection = false
    
    private var streak: Streak? {
        streaks.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.08, green: 0.08, blue: 0.15),
                        Color(red: 0.12, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Welcome header
                        welcomeHeader
                        
                        // Streak card
                        streakCard
                        
                        // Main pray button
                        prayButton
                        
                        // Quick actions
                        quickActions
                        
                        // Blocked apps status
                        if screenTimeManager.hasSelection {
                            blockedAppsStatus
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(systemName: "cross.fill")
                        .foregroundColor(.indigo)
                }
            }
            .fullScreenCover(isPresented: $showMoodSelection) {
                MoodSelectionView()
            }
            .sheet(isPresented: $showAppSelection) {
                AppSelectionView { selection in
                    screenTimeManager.updateSelection(selection)
                }
            }
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(spacing: 8) {
            Text(greeting)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Ready to connect with God?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Streak Card
    private var streakCard: some View {
        HStack(spacing: 24) {
            // Current streak
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(streak?.currentStreak ?? 0)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("🔥")
                        .font(.title2)
                }
                Text("Day Streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.2))
            
            // Today status
            VStack(spacing: 4) {
                if streak?.hasPrayedToday == true {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                }
                Text(streak?.hasPrayedToday == true ? "Prayed Today" : "Not Yet")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white.opacity(0.2))
            
            // Total prayers
            VStack(spacing: 4) {
                Text("\(streak?.totalPrayers ?? 0)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.indigo)
                Text("Total Prayers")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
    
    // MARK: - Pray Button
    private var prayButton: some View {
        Button(action: {
            // Check if apps are selected
            if screenTimeManager.hasSelection {
                showMoodSelection = true
            } else {
                showAppSelection = true
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .indigo.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Text("🙏")
                        .font(.system(size: 50))
                }
                
                Text(screenTimeManager.hasSelection ? "Start Praying" : "Select Apps First")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                icon: "apps.iphone",
                title: "Select Apps",
                color: .blue
            ) {
                showAppSelection = true
            }
            
            QuickActionButton(
                icon: screenTimeManager.isBlocking ? "lock.fill" : "lock.open",
                title: screenTimeManager.isBlocking ? "Blocking" : "Not Blocking",
                color: screenTimeManager.isBlocking ? .orange : .gray
            ) {
                // Toggle blocking manually (for testing)
                screenTimeManager.toggleBlocking()
            }
        }
    }
    
    // MARK: - Blocked Apps Status
    private var blockedAppsStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(.indigo)
                
                Text("Protected Apps")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(screenTimeManager.selectedCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.indigo)
                    .cornerRadius(12)
            }
            
            Text("These apps will require prayer before opening")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .modelContainer(for: [
            UserSettings.self,
            BlockSelection.self,
            PrayerSession.self,
            Streak.self,
            VerseOfDay.self
        ])
}
