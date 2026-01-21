import SwiftUI
import SwiftData

/// View showing prayer statistics and streak information
struct StatsView: View {
    @Query private var streaks: [Streak]
    @Query(sort: \PrayerSession.startedAt, order: .reverse) private var sessions: [PrayerSession]
    
    private var streak: Streak? {
        streaks.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Streak card
                    streakCard
                    
                    // Quick stats
                    quickStatsGrid
                    
                    // Prayer calendar
                    calendarSection
                    
                    // Mood breakdown
                    moodBreakdownSection
                    
                    // Recent sessions
                    recentSessionsSection
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Prayer Journey")
        }
    }
    
    // MARK: - Streak Card
    private var streakCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(streak?.currentStreak ?? 0)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("days")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Streak flame
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🔥")
                        .font(.system(size: 40))
                }
            }
            
            Divider()
            
            HStack {
                StatBox(
                    title: "Longest Streak",
                    value: "\(streak?.longestStreak ?? 0)",
                    icon: "trophy.fill",
                    iconColor: .yellow
                )
                
                Divider()
                    .frame(height: 40)
                
                StatBox(
                    title: "Total Prayers",
                    value: "\(streak?.totalPrayers ?? 0)",
                    icon: "hands.sparkles.fill",
                    iconColor: .indigo
                )
                
                Divider()
                    .frame(height: 40)
                
                StatBox(
                    title: "Time Prayed",
                    value: streak?.formattedTotalTime ?? "0m",
                    icon: "clock.fill",
                    iconColor: .green
                )
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            QuickStatCard(
                title: "Prayed Today",
                value: (streak?.hasPrayedToday ?? false) ? "Yes ✓" : "Not Yet",
                color: (streak?.hasPrayedToday ?? false) ? .green : .orange
            )
            
            QuickStatCard(
                title: "Most Common Mood",
                value: streak?.mostCommonMood?.emoji ?? "—",
                subtitle: streak?.mostCommonMood?.displayName,
                color: .purple
            )
            
            QuickStatCard(
                title: "This Week",
                value: "\(sessionsThisWeek.count)",
                subtitle: "prayers",
                color: .blue
            )
            
            QuickStatCard(
                title: "Average Duration",
                value: formattedAverageDuration,
                color: .teal
            )
        }
    }
    
    // MARK: - Calendar Section
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Month")
                .font(.headline)
            
            // Simple calendar grid showing prayer days
            PrayerCalendarGrid(prayerDates: streak?.prayerDates ?? [])
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Mood Breakdown Section
    private var moodBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Distribution")
                .font(.headline)
            
            let moodCounts = streak?.moodCounts ?? [:]
            
            if moodCounts.isEmpty {
                Text("Start praying to see your mood patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(sortedMoodCounts(moodCounts), id: \.0) { moodName, count in
                    if let mood = Mood(rawValue: moodName) {
                        MoodStatRow(mood: mood, count: count, total: streak?.totalPrayers ?? 1)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Recent Sessions Section
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Prayers")
                .font(.headline)
            
            if sessions.isEmpty {
                Text("Your prayer history will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            } else {
                ForEach(sessions.prefix(5)) { session in
                    SessionRow(session: session)
                    
                    if session.id != sessions.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Helper Properties
    
    private var sessionsThisWeek: [PrayerSession] {
        sessions.filter { $0.isThisWeek }
    }
    
    private var formattedAverageDuration: String {
        guard !sessions.isEmpty else { return "—" }
        let total = sessions.reduce(0) { $0 + $1.durationSeconds }
        let average = total / sessions.count
        if average >= 60 {
            return "\(average / 60)m"
        }
        return "\(average)s"
    }
    
    private func sortedMoodCounts(_ counts: [String: Int]) -> [(String, Int)] {
        counts.sorted { $0.value > $1.value }
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct MoodStatRow: View {
    let mood: Mood
    let count: Int
    let total: Int
    
    var percentage: Double {
        Double(count) / Double(total)
    }
    
    var body: some View {
        HStack {
            Text(mood.emoji)
                .font(.title3)
            
            Text(mood.displayName)
                .font(.subheadline)
            
            Spacer()
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.indigo)
                        .frame(width: geo.size.width * percentage, height: 8)
                }
            }
            .frame(width: 100, height: 8)
            
            Text("\(count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

struct SessionRow: View {
    let session: PrayerSession
    
    var body: some View {
        HStack {
            Text(session.mood.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.mood.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.durationSeconds)s")
                    .font(.subheadline)
                    .foregroundColor(.indigo)
                
                if session.wasCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
    }
}

struct PrayerCalendarGrid: View {
    let prayerDates: [Date]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            // Day labels
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        CalendarDay(
                            day: calendar.component(.day, from: date),
                            hasPrayer: hasPrayer(on: date),
                            isToday: calendar.isDateInToday(date)
                        )
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasPrayer(on date: Date) -> Bool {
        prayerDates.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}

struct CalendarDay: View {
    let day: Int
    let hasPrayer: Bool
    let isToday: Bool
    
    var body: some View {
        ZStack {
            if hasPrayer {
                Circle()
                    .fill(Color.indigo.opacity(0.3))
            }
            
            if isToday {
                Circle()
                    .strokeBorder(Color.indigo, lineWidth: 2)
            }
            
            Text("\(day)")
                .font(.caption)
                .foregroundColor(hasPrayer ? .indigo : .primary)
        }
        .frame(height: 32)
    }
}

// MARK: - Preview
#Preview {
    StatsView()
}
