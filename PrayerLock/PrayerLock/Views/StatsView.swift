import SwiftUI

struct StatsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Level Progress Card
                        LevelProgressCard()
                        
                        // Stats Overview
                        StatsOverviewGrid()
                        
                        // Tab selector
                        Picker("View", selection: $selectedTab) {
                            Text("Challenges").tag(0)
                            Text("Achievements").tag(1)
                            Text("History").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // Content based on tab
                        switch selectedTab {
                        case 0:
                            DailyChallengesView()
                        case 1:
                            AchievementsGridView()
                        case 2:
                            PrayerHistoryView()
                        default:
                            EmptyView()
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Your Journey")
        }
    }
}

// MARK: - Level Progress Card
struct LevelProgressCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassCard {
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    LevelBadge(level: appState.currentLevel, size: 80)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Level \(appState.currentLevel)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(appState.levelTitle)
                            .font(.headline)
                            .foregroundStyle(appState.settings.theme.gradient)
                        
                        Text("\(appState.settings.totalXP) Total XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress to Level \(appState.currentLevel + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(appState.levelProgress.progress * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(appState.settings.theme.gradient)
                    }
                    
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
}

// MARK: - Stats Overview Grid
struct StatsOverviewGrid: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatTile(
                icon: "flame.fill",
                value: "\(appState.streak.currentStreak)",
                label: "Current Streak",
                color: .orange
            )
            
            StatTile(
                icon: "trophy.fill",
                value: "\(appState.streak.longestStreak)",
                label: "Best Streak",
                color: .yellow
            )
            
            StatTile(
                icon: "hands.clap.fill",
                value: "\(appState.streak.totalPrayers)",
                label: "Total Prayers",
                color: appState.settings.theme.primaryColor
            )
            
            StatTile(
                icon: "clock.fill",
                value: formatMinutes(appState.streak.totalMinutesPrayed),
                label: "Time Prayed",
                color: appState.settings.theme.secondaryColor
            )
            
            StatTile(
                icon: "star.fill",
                value: "\(appState.achievements.filter { $0.isUnlocked }.count)",
                label: "Achievements",
                color: .purple
            )
            
            StatTile(
                icon: "checkmark.circle.fill",
                value: "\(appState.settings.dailyChallengesCompleted)",
                label: "Challenges",
                color: .green
            )
        }
        .padding(.horizontal)
    }
    
    func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

struct StatTile: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Daily Challenges View
struct DailyChallengesView: View {
    @EnvironmentObject var appState: AppState
    
    var completedCount: Int {
        appState.dailyChallenges.filter { $0.isCompleted }.count
    }
    
    var totalXPAvailable: Int {
        appState.dailyChallenges.reduce(0) { $0 + $1.xpReward }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Challenges")
                        .font(.headline)
                    Text("\(completedCount)/\(appState.dailyChallenges.count) completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(totalXPAvailable) XP")
                        .font(.headline)
                        .foregroundStyle(appState.settings.theme.gradient)
                    Text("available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            ForEach(appState.dailyChallenges) { challenge in
                ChallengeCard(challenge: challenge)
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Achievements Grid View
struct AchievementsGridView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var categories: [Achievement.AchievementCategory] {
        [.streak, .prayers, .time, .special]
    }
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return appState.achievements.filter { $0.category == category }
        }
        return appState.achievements
    }
    
    var unlockedCount: Int {
        appState.achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Progress
            HStack {
                Text("\(unlockedCount)/\(appState.achievements.count) Unlocked")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Achievements grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(filteredAchievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? appState.settings.theme.gradient : LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Prayer History View
struct PrayerHistoryView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            // Weekly calendar
            WeeklyCalendarView()
            
            // Mood breakdown
            MoodBreakdownView()
        }
        .padding(.horizontal)
    }
}

struct WeeklyCalendarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("This Week")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(0..<7) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
                        let hasPrayed = checkIfPrayed(on: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        VStack(spacing: 8) {
                            Text(dayLabel(for: date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            ZStack {
                                Circle()
                                    .fill(hasPrayed ? appState.settings.theme.gradient : LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 36, height: 36)
                                
                                if hasPrayed {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                
                                if isToday {
                                    Circle()
                                        .strokeBorder(appState.settings.theme.primaryColor, lineWidth: 2)
                                        .frame(width: 42, height: 42)
                                }
                            }
                            
                            Text(dateLabel(for: date))
                                .font(.caption2)
                                .foregroundColor(isToday ? appState.settings.theme.primaryColor : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func checkIfPrayed(on date: Date) -> Bool {
        guard let lastPrayer = appState.streak.lastPrayerDate else { return false }
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return appState.streak.hasPrayedToday()
        }
        
        let daysDifference = calendar.dateComponents([.day], from: date, to: lastPrayer).day ?? 0
        return daysDifference >= 0 && daysDifference < appState.streak.currentStreak
    }
}

struct MoodBreakdownView: View {
    @EnvironmentObject var appState: AppState
    
    var moodData: [(mood: PrayerMood, count: Int)] {
        PrayerMood.allCases.map { mood in
            (mood, appState.streak.prayersByMood[mood.rawValue] ?? 0)
        }.sorted { $0.count > $1.count }
    }
    
    var maxCount: Int {
        moodData.map { $0.count }.max() ?? 1
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                Text("Prayer Moods")
                    .font(.headline)
                
                ForEach(moodData, id: \.mood) { item in
                    HStack(spacing: 12) {
                        Image(systemName: item.mood.icon)
                            .foregroundStyle(appState.settings.theme.gradient)
                            .frame(width: 24)
                        
                        Text(item.mood.rawValue)
                            .font(.subheadline)
                            .frame(width: 80, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(appState.settings.theme.gradient)
                                    .frame(width: maxCount > 0 ? geometry.size.width * CGFloat(item.count) / CGFloat(maxCount) : 0, height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        Text("\(item.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .trailing)
                    }
                }
            }
        }
    }
}

// MARK: - Achievements View (Full Screen)
struct AchievementsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: Achievement.AchievementCategory? = nil
    
    var categories: [Achievement.AchievementCategory] {
        [.streak, .prayers, .time, .special]
    }
    
    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return appState.achievements.filter { $0.category == category }
        }
        return appState.achievements
    }
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Achievements list
                    ForEach(filteredAchievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Achievements")
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? appState.settings.theme.gradient
                            : LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.title3)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked, let date = achievement.unlockedDate {
                    Text("Unlocked \(date, style: .date)")
                        .font(.caption2)
                        .foregroundColor(appState.settings.theme.primaryColor)
                }
            }
            
            Spacer()
            
            VStack {
                Text("+\(achievement.xpReward)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(achievement.isUnlocked ? .green : .secondary)
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    StatsView()
        .environmentObject(AppState())
}
