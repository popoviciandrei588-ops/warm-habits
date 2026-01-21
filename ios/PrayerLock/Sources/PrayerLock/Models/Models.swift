import Foundation
import SwiftData

// MARK: - UserSettings

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Subscription-gated onboarding completion (separate from StoreKit entitlements).
    var hasCompletedOnboarding: Bool

    /// Next prayer session lock duration. Default: 60 seconds.
    var lockDurationSeconds: Int

    /// If true, show a verse screen after a completed prayer.
    var showVerseAfterPrayer: Bool

    /// Optional: last selected mood key for convenience.
    var lastMoodKey: String?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        hasCompletedOnboarding: Bool = false,
        lockDurationSeconds: Int = 60,
        showVerseAfterPrayer: Bool = true,
        lastMoodKey: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.lockDurationSeconds = lockDurationSeconds
        self.showVerseAfterPrayer = showVerseAfterPrayer
        self.lastMoodKey = lastMoodKey
    }
}

// MARK: - BlockSelection

@Model
final class BlockSelection {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var updatedAt: Date

    /// Persisted `FamilyActivitySelection` JSON (encoded as Data).
    var selectionData: Data?

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        updatedAt: Date = .now,
        selectionData: Data? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.selectionData = selectionData
    }
}

// MARK: - PrayerSession

@Model
final class PrayerSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var completedAt: Date?

    var moodKey: String
    var moodFreeText: String?

    var durationSeconds: Int
    var prayerText: String
    var verseReference: String?

    var didComplete: Bool

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        completedAt: Date? = nil,
        moodKey: String,
        moodFreeText: String? = nil,
        durationSeconds: Int,
        prayerText: String,
        verseReference: String? = nil,
        didComplete: Bool = false
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.moodKey = moodKey
        self.moodFreeText = moodFreeText
        self.durationSeconds = durationSeconds
        self.prayerText = prayerText
        self.verseReference = verseReference
        self.didComplete = didComplete
    }
}

// MARK: - Streak

@Model
final class Streak {
    @Attribute(.unique) var id: UUID
    var current: Int
    var longest: Int
    var lastPrayerDay: Date?

    init(
        id: UUID = UUID(),
        current: Int = 0,
        longest: Int = 0,
        lastPrayerDay: Date? = nil
    ) {
        self.id = id
        self.current = current
        self.longest = longest
        self.lastPrayerDay = lastPrayerDay
    }
}

// MARK: - VerseOfDay

@Model
final class VerseOfDay {
    @Attribute(.unique) var id: UUID
    /// Store start-of-day date for easy “one per day” semantics.
    var day: Date
    var reference: String
    var text: String

    init(
        id: UUID = UUID(),
        day: Date,
        reference: String,
        text: String
    ) {
        self.id = id
        self.day = day
        self.reference = reference
        self.text = text
    }
}

