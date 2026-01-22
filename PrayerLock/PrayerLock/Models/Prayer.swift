import Foundation

enum PrayerMood: String, CaseIterable, Codable {
    case gratitude = "Gratitude"
    case peace = "Peace"
    case strength = "Strength"
    case hope = "Hope"
    case forgiveness = "Forgiveness"
    
    var icon: String {
        switch self {
        case .gratitude: return "heart.fill"
        case .peace: return "leaf.fill"
        case .strength: return "bolt.fill"
        case .hope: return "sun.max.fill"
        case .forgiveness: return "hands.clap.fill"
        }
    }
    
    var color: String {
        switch self {
        case .gratitude: return "PrayerPink"
        case .peace: return "PrayerBlue"
        case .strength: return "PrayerOrange"
        case .hope: return "PrayerYellow"
        case .forgiveness: return "PrayerPurple"
        }
    }
}

struct Prayer: Identifiable, Codable {
    let id: UUID
    let mood: PrayerMood
    let text: String
    let verse: String
    let verseReference: String
    
    init(id: UUID = UUID(), mood: PrayerMood, text: String, verse: String, verseReference: String) {
        self.id = id
        self.mood = mood
        self.text = text
        self.verse = verse
        self.verseReference = verseReference
    }
}

// MARK: - Prayer Collection
struct PrayerCollection {
    static let prayers: [PrayerMood: [Prayer]] = [
        .gratitude: [
            Prayer(
                mood: .gratitude,
                text: "Heavenly Father, I come before You with a heart full of gratitude. Thank You for Your countless blessings, for the breath in my lungs, and for Your unfailing love. Help me to always recognize Your goodness in my life. Amen.",
                verse: "Give thanks in all circumstances; for this is God's will for you in Christ Jesus.",
                verseReference: "1 Thessalonians 5:18"
            ),
            Prayer(
                mood: .gratitude,
                text: "Lord, I thank You for this new day and all the possibilities it holds. Open my eyes to see Your hand at work in every moment. Fill my heart with thankfulness that overflows to others. Amen.",
                verse: "Every good and perfect gift is from above, coming down from the Father of the heavenly lights.",
                verseReference: "James 1:17"
            )
        ],
        .peace: [
            Prayer(
                mood: .peace,
                text: "Prince of Peace, calm my anxious thoughts and quiet my worried heart. Help me to rest in Your presence and trust in Your perfect plan. Let Your peace, which surpasses all understanding, guard my heart and mind. Amen.",
                verse: "Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.",
                verseReference: "John 14:27"
            ),
            Prayer(
                mood: .peace,
                text: "Dear Lord, in the midst of life's storms, be my anchor. Help me to find stillness in Your presence and rest in the knowledge that You are in control. Grant me the serenity to accept what I cannot change. Amen.",
                verse: "Be still, and know that I am God.",
                verseReference: "Psalm 46:10"
            )
        ],
        .strength: [
            Prayer(
                mood: .strength,
                text: "Almighty God, I feel weak and weary. Pour Your strength into my spirit. When I am faint, renew my energy. When I stumble, lift me up. Remind me that Your power is made perfect in my weakness. Amen.",
                verse: "I can do all things through Christ who strengthens me.",
                verseReference: "Philippians 4:13"
            ),
            Prayer(
                mood: .strength,
                text: "Lord of Hosts, be my fortress and my shield today. Give me courage to face every challenge and wisdom to overcome every obstacle. Let me draw strength from Your eternal power. Amen.",
                verse: "The Lord is my strength and my shield; my heart trusts in him, and he helps me.",
                verseReference: "Psalm 28:7"
            )
        ],
        .hope: [
            Prayer(
                mood: .hope,
                text: "God of Hope, even when darkness surrounds me, help me to see Your light. Restore my hope and remind me that Your plans for me are good. Fill me with joy and peace as I trust in You. Amen.",
                verse: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
                verseReference: "Jeremiah 29:11"
            ),
            Prayer(
                mood: .hope,
                text: "Faithful Father, when my circumstances seem hopeless, anchor my soul in Your promises. You are the God who makes a way where there seems to be no way. I place my hope in You alone. Amen.",
                verse: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles.",
                verseReference: "Isaiah 40:31"
            )
        ],
        .forgiveness: [
            Prayer(
                mood: .forgiveness,
                text: "Merciful Father, I come before You seeking forgiveness for my sins and shortcomings. Cleanse my heart and renew my spirit. Help me to extend the same grace to others that You have shown to me. Amen.",
                verse: "If we confess our sins, he is faithful and just and will forgive us our sins and purify us from all unrighteousness.",
                verseReference: "1 John 1:9"
            ),
            Prayer(
                mood: .forgiveness,
                text: "Lord Jesus, teach me to forgive as You have forgiven me. Release any bitterness from my heart and fill me with Your compassion. Help me to let go of past hurts and walk in Your freedom. Amen.",
                verse: "Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you.",
                verseReference: "Ephesians 4:32"
            )
        ]
    ]
    
    static func randomPrayer(for mood: PrayerMood) -> Prayer {
        let moodPrayers = prayers[mood] ?? []
        return moodPrayers.randomElement() ?? Prayer(
            mood: mood,
            text: "Lord, be with me in this moment. Guide my thoughts and actions. Amen.",
            verse: "The Lord is near to all who call on him.",
            verseReference: "Psalm 145:18"
        )
    }
}
