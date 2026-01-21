import Foundation
import SwiftData

@Model
final class PrayerSession {
    var id: UUID
    var date: Date
    var durationSeconds: Int
    var mood: String
    var prayerText: String
    
    init(date: Date = Date(), durationSeconds: Int, mood: String, prayerText: String) {
        self.id = UUID()
        self.date = date
        self.durationSeconds = durationSeconds
        self.mood = mood
        self.prayerText = prayerText
    }
}
