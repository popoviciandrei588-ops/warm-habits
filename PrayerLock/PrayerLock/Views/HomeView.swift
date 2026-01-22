import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showAllChallenges = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Profile & Level Card
                        ProfileLevelCard()
                        
                        // Streak & Stats Row
                        StreakStatsRow()
                        
                        // Daily Challenges
                        DailyChallengesSection()
                        
                        // Mood Selector
                        MoodSelectorSection()
                        
                        // Pray Now Button
                        PulsingButton(title: "Start Prayer", icon: "hands.clap.fill") {
                            appState.startPrayer()
                        }
                        .padding(.horizontal)
                        
                        // Blocking Status
                        BlockingStatusCard()
                        
                        // Recent Achievements
                        RecentAchievementsSection()
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Prayer Lock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    LevelBadge(level: appState.currentLevel, size: 36)
                }
            }
        }
    }
}

// MARK: - Profile Level Card
struct ProfileLevelCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassCard {
            HStack(spacing: 20) {
                LevelBadge(level: appState.currentLevel, size: 70)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(greeting)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(appState.levelTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    XPProgressBar(
                        progress: appState.levelProgress.progress,
                        currentXP: appState.levelProgress.current,
                        neededXP: appState.levelProgress.needed
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
}

// MARK: - Streak Stats Row
struct StreakStatsRow: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 15) {
            // Streak Card
            GlassCard {
                HStack(spacing: 15) {
                    StreakFlame(streak: appState.streak.currentStreak)
                    
                    VStack(alignment: .leading) {
                        Text("\(appState.streak.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Total XP Card
            GlassCard {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(appState.settings.totalXP)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Total XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Prayers Today
            GlassCard {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "hands.clap.fill")
                            .foregroundStyle(appState.settings.theme.gradient)
                        Text("\(appState.streak.todayPrayerCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("Today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Daily Challenges Section
struct DailyChallengesSection: View {
    @EnvironmentObject var appState: AppState
    
    var completedCount: Int {
        appState.dailyChallenges.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Challenges")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completedCount)/\(appState.dailyChallenges.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(appState.dailyChallenges) { challenge in
                        CompactChallengeCard(challenge: challenge)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CompactChallengeCard: View {
    let challenge: DailyChallenge
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: challenge.icon)
                    .foregroundColor(challenge.isCompleted ? .green : appState.settings.theme.primaryColor)
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text("+\(challenge.xpReward)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(appState.settings.theme.primaryColor)
                }
            }
            
            Text(challenge.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 5)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(challenge.isCompleted ? Color.green : appState.settings.theme.primaryColor)
                        .frame(width: geometry.size.width * challenge.progressPercent, height: 5)
                }
            }
            .frame(height: 5)
            
            Text("\(challenge.progress)/\(challenge.target)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

// MARK: - Mood Selector Section
struct MoodSelectorSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(PrayerMood.allCases, id: \.self) { mood in
                        MoodChip(
                            mood: mood,
                            isSelected: appState.settings.selectedMood == mood
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                appState.selectMood(mood)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Blocking Status Card
struct BlockingStatusCard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassCard {
            HStack {
                ZStack {
                    Circle()
                        .fill(screenTimeManager.isBlocking ? appState.settings.theme.primaryColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: screenTimeManager.isBlocking ? "lock.fill" : "lock.open.fill")
                        .font(.title2)
                        .foregroundColor(screenTimeManager.isBlocking ? appState.settings.theme.primaryColor : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(screenTimeManager.isBlocking ? "App Blocking Active" : "App Blocking Disabled")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(screenTimeManager.selectedAppCount) apps selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { screenTimeManager.isBlocking },
                    set: { newValue in
                        if newValue {
                            screenTimeManager.enableBlocking()
                        } else {
                            screenTimeManager.disableBlocking()
                        }
                    }
                ))
                .labelsHidden()
                .tint(appState.settings.theme.primaryColor)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Recent Achievements Section
struct RecentAchievementsSection: View {
    @EnvironmentObject var appState: AppState
    
    var recentAchievements: [Achievement] {
        appState.achievements
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? .distantPast) > ($1.unlockedDate ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }
    
    var nextAchievement: Achievement? {
        appState.achievements.first { !$0.isUnlocked }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: AchievementsView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(appState.settings.theme.primaryColor)
                }
            }
            .padding(.horizontal)
            
            if recentAchievements.isEmpty {
                // Show next achievement to unlock
                if let next = nextAchievement {
                    GlassCard {
                        HStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: next.icon)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Next Achievement")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(next.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(next.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("+\(next.xpReward) XP")
                                .font(.caption)
                                .foregroundColor(appState.settings.theme.primaryColor)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(recentAchievements) { achievement in
                            AchievementBadge(achievement: achievement)
                        }
                        
                        if let next = nextAchievement {
                            AchievementBadge(achievement: next)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
