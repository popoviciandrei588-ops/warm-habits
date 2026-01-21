import Foundation
import SwiftData

/// Represents a completed prayer session
@Model
final class PrayerSession {
    /// Unique identifier
    var id: UUID
    
    /// When the prayer session started
    var startedAt: Date
    
    /// When the prayer session ended (completed)
    var completedAt: Date?
    
    /// Duration in seconds that the user actually prayed
    var durationSeconds: Int
    
    /// The mood/feeling selected for this session
    var moodRawValue: String
    
    /// Optional custom mood text entered by user
    var customMoodText: String?
    
    /// The prayer text that was shown
    var prayerText: String
    
    /// The Bible reference shown (if any)
    var bibleReference: String?
    
    /// Whether the session was completed (timer finished)
    var wasCompleted: Bool
    
    /// Whether the session was interrupted
    var wasInterrupted: Bool
    
    /// Apps that were unblocked after this session
    var unlockedAppCount: Int
    
    init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        durationSeconds: Int = 60,
        moodRawValue: String = Mood.grateful.rawValue,
        customMoodText: String? = nil,
        prayerText: String = "",
        bibleReference: String? = nil,
        wasCompleted: Bool = false,
        wasInterrupted: Bool = false,
        unlockedAppCount: Int = 0
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.moodRawValue = moodRawValue
        self.customMoodText = customMoodText
        self.prayerText = prayerText
        self.bibleReference = bibleReference
        self.wasCompleted = wasCompleted
        self.wasInterrupted = wasInterrupted
        self.unlockedAppCount = unlockedAppCount
    }
    
    /// Get the mood enum value
    var mood: Mood {
        Mood(rawValue: moodRawValue) ?? .grateful
    }
    
    /// Mark the session as completed
    func complete() {
        self.completedAt = Date()
        self.wasCompleted = true
    }
    
    /// Mark the session as interrupted
    func interrupt() {
        self.completedAt = Date()
        self.wasInterrupted = true
        self.wasCompleted = false
    }
}

// MARK: - Mood Enum
enum Mood: String, CaseIterable, Identifiable, Codable {
    case grateful = "grateful"
    case anxious = "anxious"
    case joyful = "joyful"
    case sad = "sad"
    case stressed = "stressed"
    case hopeful = "hopeful"
    case frustrated = "frustrated"
    case peaceful = "peaceful"
    case overwhelmed = "overwhelmed"
    case lonely = "lonely"
    case thankful = "thankful"
    case fearful = "fearful"
    case content = "content"
    case angry = "angry"
    case confused = "confused"
    case excited = "excited"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var emoji: String {
        switch self {
        case .grateful: return "🙏"
        case .anxious: return "😰"
        case .joyful: return "😊"
        case .sad: return "😢"
        case .stressed: return "😫"
        case .hopeful: return "🌟"
        case .frustrated: return "😤"
        case .peaceful: return "😌"
        case .overwhelmed: return "🌊"
        case .lonely: return "💔"
        case .thankful: return "💝"
        case .fearful: return "😨"
        case .content: return "☺️"
        case .angry: return "😠"
        case .confused: return "😕"
        case .excited: return "🎉"
        }
    }
    
    var color: String {
        switch self {
        case .grateful, .thankful: return "green"
        case .anxious, .stressed, .overwhelmed: return "orange"
        case .joyful, .hopeful, .excited: return "yellow"
        case .sad, .lonely: return "blue"
        case .frustrated, .angry: return "red"
        case .peaceful, .content: return "teal"
        case .fearful: return "purple"
        case .confused: return "gray"
        }
    }
}

// MARK: - Date Helpers
extension PrayerSession {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startedAt)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(startedAt)
    }
    
    var isThisWeek: Bool {
        Calendar.current.isDate(startedAt, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
