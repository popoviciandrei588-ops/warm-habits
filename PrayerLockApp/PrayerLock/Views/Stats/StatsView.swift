import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var statsManager = StatsManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PLSpacing.lg) {
                    // Streak section
                    streakSection
                    
                    // Stats overview
                    statsOverview
                    
                    // Weekly chart
                    weeklyChart
                    
                    // Mood distribution
                    moodDistribution
                }
                .padding(.horizontal, PLSpacing.md)
                .padding(.bottom, PLSpacing.xxl)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Stats")
            .onAppear {
                statsManager.setup(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Streak Section
    private var streakSection: some View {
        VStack(spacing: PLSpacing.lg) {
            HStack(spacing: PLSpacing.xl) {
                VStack(spacing: PLSpacing.xs) {
                    StreakBadge(streak: statsManager.currentStreak, size: .large)
                    Text("Current Streak")
                        .font(PLTypography.labelMedium)
                        .foregroundColor(.secondary)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 60)
                
                VStack(spacing: PLSpacing.xs) {
                    Text("\(statsManager.longestStreak)")
                        .font(PLTypography.headlineLarge)
                        .foregroundColor(.primary)
                    Text("Longest Streak")
                        .font(PLTypography.labelMedium)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(PLSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.xl))
        .plShadowSmall()
    }
    
    // MARK: - Stats Overview
    private var statsOverview: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Text("Overview")
                .font(PLTypography.titleMedium)
                .foregroundColor(.primary)
            
            HStack(spacing: PLSpacing.sm) {
                StatCard(
                    icon: "clock.fill",
                    title: "Total Minutes",
                    value: "\(statsManager.totalMinutes)",
                    color: Color(hex: "3B82F6")
                )
                
                StatCard(
                    icon: "hands.sparkles.fill",
                    title: "Total Sessions",
                    value: "\(statsManager.totalSessions)",
                    color: Color(hex: "8B5CF6")
                )
            }
            
            HStack(spacing: PLSpacing.sm) {
                StatCard(
                    icon: "sun.max.fill",
                    title: "Today",
                    value: "\(statsManager.todaySessions)",
                    subtitle: "sessions",
                    color: Color(hex: "F59E0B")
                )
                
                StatCard(
                    icon: "calendar",
                    title: "This Week",
                    value: "\(weeklyTotal)",
                    subtitle: "sessions",
                    color: Color(hex: "10B981")
                )
            }
        }
    }
    
    private var weeklyTotal: Int {
        statsManager.weeklyData.reduce(0) { $0 + $1.sessions }
    }
    
    // MARK: - Weekly Chart
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Text("This Week")
                .font(PLTypography.titleMedium)
                .foregroundColor(.primary)
            
            Chart(statsManager.weeklyData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Sessions", data.sessions)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(PLRadius.sm)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding(PLSpacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
        .plShadowSmall()
    }
    
    // MARK: - Mood Distribution
    private var moodDistribution: some View {
        VStack(alignment: .leading, spacing: PLSpacing.md) {
            Text("Mood Patterns")
                .font(PLTypography.titleMedium)
                .foregroundColor(.primary)
            
            if statsManager.moodDistribution.isEmpty {
                Text("Complete more prayer sessions to see your mood patterns")
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.secondary)
                    .padding(.vertical, PLSpacing.lg)
            } else {
                VStack(spacing: PLSpacing.sm) {
                    ForEach(statsManager.moodDistribution.prefix(5)) { data in
                        HStack(spacing: PLSpacing.sm) {
                            Image(systemName: data.mood.icon)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: data.mood.color))
                                .frame(width: 24)
                            
                            Text(data.mood.rawValue)
                                .font(PLTypography.bodyMedium)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: PLRadius.sm)
                                        .fill(Color.gray.opacity(0.1))
                                    
                                    RoundedRectangle(cornerRadius: PLRadius.sm)
                                        .fill(Color(hex: data.mood.color))
                                        .frame(width: geo.size.width * data.percentage / 100)
                                }
                            }
                            .frame(width: 80, height: 8)
                            
                            Text("\(data.count)")
                                .font(PLTypography.labelMedium)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(PLSpacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
        .plShadowSmall()
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [PrayerSession.self, DailyStreak.self])
}
