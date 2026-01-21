import Foundation
import SwiftData

enum StreakService {
    @MainActor
    static func registerCompletedPrayer(on date: Date, modelContext: ModelContext) {
        let fetch = FetchDescriptor<Streak>()
        let streak = (try? modelContext.fetch(fetch).first) ?? {
            let s = Streak()
            modelContext.insert(s)
            return s
        }()

        let cal = Calendar.current
        let today = cal.startOfDay(for: date)

        if let last = streak.lastPrayerDay {
            let lastDay = cal.startOfDay(for: last)
            if lastDay == today {
                // already counted today
                return
            }
            let yesterday = cal.date(byAdding: .day, value: -1, to: today)
            if yesterday == lastDay {
                streak.current += 1
            } else {
                streak.current = 1
            }
        } else {
            streak.current = 1
        }

        streak.longest = max(streak.longest, streak.current)
        streak.lastPrayerDay = today
    }
}

