import Foundation

struct PrayerDraft: Sendable {
    let text: String
    let verseReference: String?
}

/// Generates short, Bible-rooted prayers offline (templates) with an optional remote stub.
struct PrayerComposer {
    enum Mode: Sendable {
        case offlineTemplates
        case remoteStub
    }

    var mode: Mode = .offlineTemplates

    func compose(mood: Mood, freeText: String?) async -> PrayerDraft {
        switch mode {
        case .offlineTemplates:
            return composeOffline(mood: mood, freeText: freeText)
        case .remoteStub:
            // Stub for future API wiring.
            // In production, call your backend, validate content, and fall back to templates.
            return composeOffline(mood: mood, freeText: freeText)
        }
    }

    private func composeOffline(mood: Mood, freeText: String?) -> PrayerDraft {
        let userNeed = (freeText?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }

        // Keep prayers short, direct, and reverent. Avoid long quotations; include short references.
        switch mood {
        case .anxious:
            return PrayerDraft(
                text: """
                Father, You see my anxious thoughts. Quiet my heart and steady my breathing.
                Help me trust You with what I can’t control, and lead me in Your peace today.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Philippians 4:6–7"
            )
        case .stressed:
            return PrayerDraft(
                text: """
                Lord, I feel weighed down. Give me wisdom for what to do next and courage to do it.
                Teach me to take Your yoke and to rest in You.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Matthew 11:28–30"
            )
        case .distracted:
            return PrayerDraft(
                text: """
                God, my attention feels pulled in every direction.
                Turn my eyes back to what is good and lasting. Help me choose what matters most.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Colossians 3:2"
            )
        case .tired:
            return PrayerDraft(
                text: """
                Father, I’m tired. Strengthen me where I’m weak and give me clean, quiet rest.
                Renew my mind and help me walk one step at a time with You.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Isaiah 40:31"
            )
        case .lonely:
            return PrayerDraft(
                text: """
                Lord, I feel alone. Remind me that You are near and You do not leave me.
                Bring comfort, and place loving people around me in the right time.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Psalm 34:18"
            )
        case .tempted:
            return PrayerDraft(
                text: """
                Jesus, I’m being pulled toward what won’t help my soul.
                Give me a way out, strengthen my will, and fill me with Your Spirit.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "1 Corinthians 10:13"
            )
        case .grateful:
            return PrayerDraft(
                text: """
                Father, thank You for Your kindness in my life.
                Help me notice Your gifts today and respond with love and obedience.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "1 Thessalonians 5:18"
            )
        case .hopeful:
            return PrayerDraft(
                text: """
                Lord, thank You for hope that isn’t fragile.
                Guide my steps, guard my heart, and keep me faithful in the small things today.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Romans 15:13"
            )
        case .sad:
            return PrayerDraft(
                text: """
                Father, my heart feels heavy.
                Hold me close, comfort me, and help me take refuge in Your love.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "Psalm 23:4"
            )
        case .angry:
            return PrayerDraft(
                text: """
                Lord, I’m angry. Help me slow down and be quick to listen.
                Heal what’s wounded in me, and lead me into patience and peace.
                \(needLine(userNeed))
                In Jesus’ name, amen.
                """.trimmedLines(),
                verseReference: "James 1:19–20"
            )
        }
    }

    private func needLine(_ need: String?) -> String {
        guard let need else { return "" }
        return "God, You know what I mean when I say: \(need)."
    }
}

private extension String {
    func trimmedLines() -> String {
        split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

