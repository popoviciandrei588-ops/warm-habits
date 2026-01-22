import Foundation

struct BibleVerse: Identifiable, Codable {
    let id: UUID
    let text: String
    let reference: String
    
    init(id: UUID = UUID(), text: String, reference: String) {
        self.id = id
        self.text = text
        self.reference = reference
    }
}

struct DailyVerseCollection {
    static let verses: [BibleVerse] = [
        BibleVerse(
            text: "Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
            reference: "Proverbs 3:5-6"
        ),
        BibleVerse(
            text: "The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul.",
            reference: "Psalm 23:1-3"
        ),
        BibleVerse(
            text: "Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.",
            reference: "Joshua 1:9"
        ),
        BibleVerse(
            text: "Come to me, all you who are weary and burdened, and I will give you rest.",
            reference: "Matthew 11:28"
        ),
        BibleVerse(
            text: "But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control.",
            reference: "Galatians 5:22-23"
        ),
        BibleVerse(
            text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
            reference: "Romans 8:28"
        ),
        BibleVerse(
            text: "The Lord is my light and my salvation—whom shall I fear? The Lord is the stronghold of my life—of whom shall I be afraid?",
            reference: "Psalm 27:1"
        ),
        BibleVerse(
            text: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.",
            reference: "Philippians 4:6"
        ),
        BibleVerse(
            text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
            reference: "John 3:16"
        ),
        BibleVerse(
            text: "The Lord bless you and keep you; the Lord make his face shine on you and be gracious to you; the Lord turn his face toward you and give you peace.",
            reference: "Numbers 6:24-26"
        ),
        BibleVerse(
            text: "Cast all your anxiety on him because he cares for you.",
            reference: "1 Peter 5:7"
        ),
        BibleVerse(
            text: "I have told you these things, so that in me you may have peace. In this world you will have trouble. But take heart! I have overcome the world.",
            reference: "John 16:33"
        ),
        BibleVerse(
            text: "Be still before the Lord and wait patiently for him.",
            reference: "Psalm 37:7"
        ),
        BibleVerse(
            text: "The name of the Lord is a fortified tower; the righteous run to it and are safe.",
            reference: "Proverbs 18:10"
        ),
        BibleVerse(
            text: "Create in me a pure heart, O God, and renew a steadfast spirit within me.",
            reference: "Psalm 51:10"
        ),
        BibleVerse(
            text: "Therefore, if anyone is in Christ, the new creation has come: The old has gone, the new is here!",
            reference: "2 Corinthians 5:17"
        ),
        BibleVerse(
            text: "May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.",
            reference: "Romans 15:13"
        ),
        BibleVerse(
            text: "Your word is a lamp for my feet, a light on my path.",
            reference: "Psalm 119:105"
        ),
        BibleVerse(
            text: "In the beginning was the Word, and the Word was with God, and the Word was God.",
            reference: "John 1:1"
        ),
        BibleVerse(
            text: "The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.",
            reference: "Lamentations 3:22-23"
        ),
        BibleVerse(
            text: "Rejoice always, pray continually, give thanks in all circumstances; for this is God's will for you in Christ Jesus.",
            reference: "1 Thessalonians 5:16-18"
        ),
        BibleVerse(
            text: "But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.",
            reference: "Isaiah 40:31"
        ),
        BibleVerse(
            text: "Love is patient, love is kind. It does not envy, it does not boast, it is not proud.",
            reference: "1 Corinthians 13:4"
        ),
        BibleVerse(
            text: "For where two or three gather in my name, there am I with them.",
            reference: "Matthew 18:20"
        ),
        BibleVerse(
            text: "Ask and it will be given to you; seek and you will find; knock and the door will be opened to you.",
            reference: "Matthew 7:7"
        ),
        BibleVerse(
            text: "I will lift up my eyes to the mountains—where does my help come from? My help comes from the Lord, the Maker of heaven and earth.",
            reference: "Psalm 121:1-2"
        ),
        BibleVerse(
            text: "He heals the brokenhearted and binds up their wounds.",
            reference: "Psalm 147:3"
        ),
        BibleVerse(
            text: "This is the day that the Lord has made; let us rejoice and be glad in it.",
            reference: "Psalm 118:24"
        ),
        BibleVerse(
            text: "The Lord is close to the brokenhearted and saves those who are crushed in spirit.",
            reference: "Psalm 34:18"
        ),
        BibleVerse(
            text: "Seek first his kingdom and his righteousness, and all these things will be given to you as well.",
            reference: "Matthew 6:33"
        ),
        BibleVerse(
            text: "I am the way and the truth and the life. No one comes to the Father except through me.",
            reference: "John 14:6"
        )
    ]
    
    static func verseForToday() -> BibleVerse {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % verses.count
        return verses[index]
    }
    
    static func randomVerse() -> BibleVerse {
        verses.randomElement() ?? verses[0]
    }
}
