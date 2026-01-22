import SwiftUI
import SwiftData

@MainActor
class StatsManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalSessions: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var todaySessions: Int = 0
    @Published var weeklyData: [DayData] = []
    @Published var moodDistribution: [MoodData] = []
    
    // MARK: - Models
    struct DayData: Identifiable {
        let id = UUID()
        let day: String
        let sessions: Int
        let minutes: Int
    }
    
    struct MoodData: Identifiable {
        let id = UUID()
        let mood: MoodType
        let count: Int
        let percentage: Double
    }
    
    private var modelContext: ModelContext?
    
    // MARK: - Setup
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadStats()
    }
    
    // MARK: - Load Stats
    func loadStats() {
        guard let context = modelContext else { return }
        
        // Fetch all sessions
        let descriptor = FetchDescriptor<PrayerSession>(
            predicate: #Predicate { $0.completed == true },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let sessions = try context.fetch(descriptor)
            calculateStats(from: sessions)
        } catch {
            print("Failed to fetch sessions: \(error)")
        }
    }
    
    private func calculateStats(from sessions: [PrayerSession]) {
        totalSessions = sessions.count
        totalMinutes = sessions.reduce(0) { $0 + $1.duration } / 60
        
        // Today's sessions
        let today = Calendar.current.startOfDay(for: Date())
        todaySessions = sessions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }.count
        
        // Calculate streaks
        calculateStreaks(from: sessions)
        
        // Weekly data
        calculateWeeklyData(from: sessions)
        
        // Mood distribution
        calculateMoodDistribution(from: sessions)
    }
    
    private func calculateStreaks(from sessions: [PrayerSession]) {
        let calendar = Calendar.current
        var uniqueDays: Set<String> = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for session in sessions {
            uniqueDays.insert(dateFormatter.string(from: session.date))
        }
        
        let sortedDays = uniqueDays.sorted().reversed()
        var streak = 0
        var maxStreak = 0
        var previousDate: Date?
        
        for dayString in sortedDays {
            guard let date = dateFormatter.date(from: dayString) else { continue }
            
            if let previous = previousDate {
                let dayDifference = calendar.dateComponents([.day], from: date, to: previous).day ?? 0
                if dayDifference == 1 {
                    streak += 1
                } else {
                    maxStreak = max(maxStreak, streak)
                    streak = 1
                }
            } else {
                // First day - check if it's today or yesterday
                let today = calendar.startOfDay(for: Date())
                let dayDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
                if dayDiff <= 1 {
                    streak = 1
                }
            }
            
            previousDate = date
        }
        
        maxStreak = max(maxStreak, streak)
        currentStreak = streak
        longestStreak = maxStreak
    }
    
    private func calculateWeeklyData(from sessions: [PrayerSession]) {
        let calendar = Calendar.current
        let today = Date()
        var data: [DayData] = []
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            
            let daySessions = sessions.filter {
                calendar.isDate($0.date, inSameDayAs: dayStart)
            }
            
            let sessionCount = daySessions.count
            let minutes = daySessions.reduce(0) { $0 + $1.duration } / 60
            
            data.append(DayData(
                day: dayFormatter.string(from: date),
                sessions: sessionCount,
                minutes: minutes
            ))
        }
        
        weeklyData = data
    }
    
    private func calculateMoodDistribution(from sessions: [PrayerSession]) {
        var moodCounts: [MoodType: Int] = [:]
        
        for session in sessions {
            if let mood = MoodType(rawValue: session.mood) {
                moodCounts[mood, default: 0] += 1
            }
        }
        
        let total = Double(sessions.count)
        
        moodDistribution = moodCounts.map { mood, count in
            MoodData(
                mood: mood,
                count: count,
                percentage: total > 0 ? Double(count) / total * 100 : 0
            )
        }.sorted { $0.count > $1.count }
    }
    
    // MARK: - Record Session
    func recordSession(mood: MoodType, duration: Int, prayerText: String) {
        guard let context = modelContext else { return }
        
        let session = PrayerSession(
            duration: duration,
            mood: mood.rawValue,
            prayerText: prayerText,
            completed: true
        )
        
        context.insert(session)
        
        do {
            try context.save()
            loadStats()
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}
