import Foundation

struct Verse: Identifiable, Codable {
    let id: UUID
    let text: String
    let reference: String
    let translation: String
    
    init(id: UUID = UUID(), text: String, reference: String, translation: String = "NIV") {
        self.id = id
        self.text = text
        self.reference = reference
        self.translation = translation
    }
}

// MARK: - Verse Data
extension Verse {
    static let dailyVerses: [Verse] = [
        Verse(
            text: "Be still, and know that I am God; I will be exalted among the nations, I will be exalted in the earth.",
            reference: "Psalm 46:10"
        ),
        Verse(
            text: "Come to me, all you who are weary and burdened, and I will give you rest.",
            reference: "Matthew 11:28"
        ),
        Verse(
            text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.",
            reference: "Philippians 4:6"
        ),
        Verse(
            text: "The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters.",
            reference: "Psalm 23:1-2"
        ),
        Verse(
            text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
            reference: "Proverbs 3:5-6"
        ),
        Verse(
            text: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.",
            reference: "Jeremiah 29:11"
        ),
        Verse(
            text: "The peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.",
            reference: "Philippians 4:7"
        ),
        Verse(
            text: "Cast all your anxiety on him because he cares for you.",
            reference: "1 Peter 5:7"
        ),
        Verse(
            text: "I can do all this through him who gives me strength.",
            reference: "Philippians 4:13"
        ),
        Verse(
            text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles.",
            reference: "Isaiah 40:31"
        ),
        Verse(
            text: "The Lord is close to the brokenhearted and saves those who are crushed in spirit.",
            reference: "Psalm 34:18"
        ),
        Verse(
            text: "Therefore do not worry about tomorrow, for tomorrow will worry about itself.",
            reference: "Matthew 6:34"
        ),
        Verse(
            text: "Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.",
            reference: "John 14:27"
        ),
        Verse(
            text: "He gives strength to the weary and increases the power of the weak.",
            reference: "Isaiah 40:29"
        ),
        Verse(
            text: "When I am afraid, I put my trust in you.",
            reference: "Psalm 56:3"
        )
    ]
    
    static func verseOfTheDay() -> Verse {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % dailyVerses.count
        return dailyVerses[index]
    }
}
