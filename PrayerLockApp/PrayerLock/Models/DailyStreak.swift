import Foundation
import SwiftData

@Model
final class DailyStreak {
    var id: UUID
    var date: Date
    var sessionsCount: Int
    var totalMinutes: Int
    var moods: [String]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        sessionsCount: Int = 0,
        totalMinutes: Int = 0,
        moods: [String] = []
    ) {
        self.id = id
        self.date = date
        self.sessionsCount = sessionsCount
        self.totalMinutes = totalMinutes
        self.moods = moods
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
