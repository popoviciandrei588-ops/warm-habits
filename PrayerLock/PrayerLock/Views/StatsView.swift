import SwiftUI

struct StatsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Main streak card
                    MainStreakCard()
                    
                    // Stats grid
                    StatsGrid()
                    
                    // Weekly activity
                    WeeklyActivityCard()
                    
                    // Achievements
                    AchievementsCard()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Your Journey")
        }
    }
}

struct MainStreakCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("\(appState.streak.currentStreak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
            }
            
            Text("Day Prayer Streak")
                .font(.headline)
            
            if appState.streak.hasPrayedToday() {
                Label("You've prayed today!", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                Text("Pray today to keep your streak!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct StatsGrid: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            StatCard(
                icon: "hands.clap.fill",
                value: "\(appState.streak.totalPrayers)",
                label: "Total Prayers",
                color: Color("PrayerBlue")
            )
            
            StatCard(
                icon: "trophy.fill",
                value: "\(appState.streak.longestStreak)",
                label: "Longest Streak",
                color: Color("PrayerYellow")
            )
            
            StatCard(
                icon: "clock.fill",
                value: formattedTotalTime,
                label: "Time in Prayer",
                color: Color("PrayerPurple")
            )
            
            StatCard(
                icon: "heart.fill",
                value: appState.settings.selectedMood.rawValue,
                label: "Current Mood",
                color: Color("PrayerPink")
            )
        }
    }
    
    var formattedTotalTime: String {
        let totalSeconds = appState.streak.totalPrayers * appState.settings.prayerDurationSeconds
        let minutes = totalSeconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct WeeklyActivityCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("This Week")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(0..<7) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
                    let hasPrayed = checkIfPrayed(on: date)
                    
                    VStack(spacing: 8) {
                        Circle()
                            .fill(hasPrayed ? Color("PrayerBlue") : Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: hasPrayed ? "checkmark" : "")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                        
                        Text(dayLabel(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
    
    func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
    
    func checkIfPrayed(on date: Date) -> Bool {
        guard let lastPrayer = appState.streak.lastPrayerDate else { return false }
        let calendar = Calendar.current
        
        // Simple check: if the date is today and we prayed today
        if calendar.isDateInToday(date) {
            return appState.streak.hasPrayedToday()
        }
        
        // For past days, check if it's within the current streak
        let daysDifference = calendar.dateComponents([.day], from: date, to: lastPrayer).day ?? 0
        return daysDifference >= 0 && daysDifference < appState.streak.currentStreak
    }
}

struct AchievementsCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.headline)
            
            VStack(spacing: 12) {
                AchievementRow(
                    icon: "star.fill",
                    title: "First Prayer",
                    description: "Complete your first prayer",
                    isUnlocked: appState.streak.totalPrayers >= 1,
                    color: .yellow
                )
                
                AchievementRow(
                    icon: "flame.fill",
                    title: "Week Warrior",
                    description: "Maintain a 7-day streak",
                    isUnlocked: appState.streak.longestStreak >= 7,
                    color: .orange
                )
                
                AchievementRow(
                    icon: "crown.fill",
                    title: "Prayer Master",
                    description: "Pray 30 times",
                    isUnlocked: appState.streak.totalPrayers >= 30,
                    color: Color("PrayerPurple")
                )
                
                AchievementRow(
                    icon: "heart.circle.fill",
                    title: "Faithful",
                    description: "30-day streak",
                    isUnlocked: appState.streak.longestStreak >= 30,
                    color: Color("PrayerPink")
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isUnlocked ? color : .gray)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .environmentObject(AppState())
}
