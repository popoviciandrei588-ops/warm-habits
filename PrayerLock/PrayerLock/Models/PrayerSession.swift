import Foundation
import SwiftData

@Model
final class PrayerSession {
    var id: UUID
    var date: Date
    var duration: Int // in seconds
    var mood: String
    var moodNote: String?
    var prayerText: String
    var completed: Bool
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: Int = 60,
        mood: String,
        moodNote: String? = nil,
        prayerText: String,
        completed: Bool = false
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.mood = mood
        self.moodNote = moodNote
        self.prayerText = prayerText
        self.completed = completed
    }
}

// MARK: - Mood Type
enum MoodType: String, CaseIterable, Identifiable {
    case anxious = "Anxious"
    case grateful = "Grateful"
    case tempted = "Tempted"
    case distracted = "Distracted"
    case lonely = "Lonely"
    case angry = "Angry"
    case peaceful = "Peaceful"
    case tired = "Tired"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .anxious: return "wind"
        case .grateful: return "heart.fill"
        case .tempted: return "flame.fill"
        case .distracted: return "bubble.left.and.bubble.right.fill"
        case .lonely: return "person.fill.questionmark"
        case .angry: return "bolt.fill"
        case .peaceful: return "leaf.fill"
        case .tired: return "moon.fill"
        }
    }
    
    var color: String {
        switch self {
        case .anxious: return "F59E0B"
        case .grateful: return "10B981"
        case .tempted: return "EF4444"
        case .distracted: return "8B5CF6"
        case .lonely: return "6366F1"
        case .angry: return "DC2626"
        case .peaceful: return "0EA5E9"
        case .tired: return "64748B"
        }
    }
}
