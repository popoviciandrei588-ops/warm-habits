import Foundation

struct Verse: Sendable {
    let reference: String
    let text: String
}

enum VerseProvider {
    // Short, paraphrase-like selections (not long quotations).
    // Replace with licensed text if you need a specific translation.
    private static let verses: [Verse] = [
        Verse(reference: "Psalm 46:10", text: "Be still — God is near, and He is God."),
        Verse(reference: "Proverbs 3:5–6", text: "Trust the Lord fully; He will guide your path."),
        Verse(reference: "Isaiah 26:3", text: "God keeps in perfect peace the one whose mind is stayed on Him."),
        Verse(reference: "Matthew 6:33", text: "Seek God first, and He will provide what you need."),
        Verse(reference: "Romans 12:2", text: "Be transformed by renewing your mind."),
        Verse(reference: "John 15:5", text: "Abide in Jesus; apart from Him, we can’t bear lasting fruit."),
        Verse(reference: "Philippians 4:8", text: "Fix your thoughts on what is true, noble, and pure."),
        Verse(reference: "2 Timothy 1:7", text: "God gives power, love, and a sound mind — not fear."),
        Verse(reference: "Psalm 23:1", text: "The Lord is your shepherd; you are not lacking."),
        Verse(reference: "Hebrews 12:2", text: "Look to Jesus — the One who begins and completes faith.")
    ]

    static func verseForToday(_ date: Date = .now) -> Verse {
        let cal = Calendar.current
        let day = cal.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (day - 1) % verses.count
        return verses[index]
    }

    static func startOfDay(_ date: Date = .now) -> Date {
        Calendar.current.startOfDay(for: date)
    }
}

