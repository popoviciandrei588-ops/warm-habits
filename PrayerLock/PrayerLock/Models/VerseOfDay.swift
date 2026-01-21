import Foundation
import SwiftData

/// Model for storing the verse of the day
@Model
final class VerseOfDay {
    /// Unique identifier
    var id: UUID
    
    /// The verse text
    var text: String
    
    /// The Bible reference (e.g., "Philippians 4:13")
    var reference: String
    
    /// Date this verse was shown
    var date: Date
    
    /// Whether this verse has been favorited
    var isFavorite: Bool
    
    /// Category/theme of the verse
    var category: String?
    
    init(
        id: UUID = UUID(),
        text: String = "",
        reference: String = "",
        date: Date = Date(),
        isFavorite: Bool = false,
        category: String? = nil
    ) {
        self.id = id
        self.text = text
        self.reference = reference
        self.date = date
        self.isFavorite = isFavorite
        self.category = category
    }
}

// MARK: - Verse Library
struct VerseLibrary {
    /// All available verses organized by category/mood
    static let verses: [String: [(text: String, reference: String)]] = [
        "grateful": [
            ("Give thanks in all circumstances; for this is God's will for you in Christ Jesus.", "1 Thessalonians 5:18"),
            ("Enter his gates with thanksgiving and his courts with praise; give thanks to him and praise his name.", "Psalm 100:4"),
            ("I will give thanks to you, Lord, with all my heart; I will tell of all your wonderful deeds.", "Psalm 9:1"),
            ("Let the peace of Christ rule in your hearts, since as members of one body you were called to peace. And be thankful.", "Colossians 3:15"),
        ],
        "anxious": [
            ("Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.", "Philippians 4:6"),
            ("Cast all your anxiety on him because he cares for you.", "1 Peter 5:7"),
            ("When anxiety was great within me, your consolation brought me joy.", "Psalm 94:19"),
            ("Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.", "John 14:27"),
        ],
        "joyful": [
            ("Rejoice in the Lord always. I will say it again: Rejoice!", "Philippians 4:4"),
            ("The joy of the Lord is your strength.", "Nehemiah 8:10"),
            ("You make known to me the path of life; you will fill me with joy in your presence, with eternal pleasures at your right hand.", "Psalm 16:11"),
            ("Though you have not seen him, you love him; and even though you do not see him now, you believe in him and are filled with an inexpressible and glorious joy.", "1 Peter 1:8"),
        ],
        "sad": [
            ("The Lord is close to the brokenhearted and saves those who are crushed in spirit.", "Psalm 34:18"),
            ("He heals the brokenhearted and binds up their wounds.", "Psalm 147:3"),
            ("Blessed are those who mourn, for they will be comforted.", "Matthew 5:4"),
            ("Weeping may stay for the night, but rejoicing comes in the morning.", "Psalm 30:5"),
        ],
        "stressed": [
            ("Come to me, all you who are weary and burdened, and I will give you rest.", "Matthew 11:28"),
            ("Be still, and know that I am God.", "Psalm 46:10"),
            ("The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters.", "Psalm 23:1-2"),
            ("I can do all this through him who gives me strength.", "Philippians 4:13"),
        ],
        "hopeful": [
            ("For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.", "Jeremiah 29:11"),
            ("May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.", "Romans 15:13"),
            ("But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.", "Isaiah 40:31"),
            ("Now faith is confidence in what we hope for and assurance about what we do not see.", "Hebrews 11:1"),
        ],
        "frustrated": [
            ("In your anger do not sin. Do not let the sun go down while you are still angry.", "Ephesians 4:26"),
            ("A gentle answer turns away wrath, but a harsh word stirs up anger.", "Proverbs 15:1"),
            ("Be completely humble and gentle; be patient, bearing with one another in love.", "Ephesians 4:2"),
            ("My dear brothers and sisters, take note of this: Everyone should be quick to listen, slow to speak and slow to become angry.", "James 1:19"),
        ],
        "peaceful": [
            ("The Lord gives strength to his people; the Lord blesses his people with peace.", "Psalm 29:11"),
            ("You will keep in perfect peace those whose minds are steadfast, because they trust in you.", "Isaiah 26:3"),
            ("And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.", "Philippians 4:7"),
            ("Now may the Lord of peace himself give you peace at all times and in every way.", "2 Thessalonians 3:16"),
        ],
        "overwhelmed": [
            ("God is our refuge and strength, an ever-present help in trouble.", "Psalm 46:1"),
            ("When I am overwhelmed, you alone know the way I should turn.", "Psalm 142:3"),
            ("Trust in the Lord with all your heart and lean not on your own understanding.", "Proverbs 3:5"),
            ("The Lord himself goes before you and will be with you; he will never leave you nor forsake you. Do not be afraid; do not be discouraged.", "Deuteronomy 31:8"),
        ],
        "lonely": [
            ("The Lord is near to all who call on him, to all who call on him in truth.", "Psalm 145:18"),
            ("Never will I leave you; never will I forsake you.", "Hebrews 13:5"),
            ("Even though I walk through the darkest valley, I will fear no evil, for you are with me.", "Psalm 23:4"),
            ("God sets the lonely in families, he leads out the prisoners with singing.", "Psalm 68:6"),
        ],
        "thankful": [
            ("Every good and perfect gift is from above, coming down from the Father of the heavenly lights.", "James 1:17"),
            ("Praise the Lord, my soul, and forget not all his benefits.", "Psalm 103:2"),
            ("O give thanks to the Lord, for he is good; for his steadfast love endures forever.", "Psalm 107:1"),
            ("Thanks be to God for his indescribable gift!", "2 Corinthians 9:15"),
        ],
        "fearful": [
            ("For God has not given us a spirit of fear, but of power and of love and of a sound mind.", "2 Timothy 1:7"),
            ("So do not fear, for I am with you; do not be dismayed, for I am your God.", "Isaiah 41:10"),
            ("When I am afraid, I put my trust in you.", "Psalm 56:3"),
            ("There is no fear in love. But perfect love drives out fear.", "1 John 4:18"),
        ],
        "content": [
            ("I have learned to be content whatever the circumstances.", "Philippians 4:11"),
            ("But godliness with contentment is great gain.", "1 Timothy 6:6"),
            ("Keep your lives free from the love of money and be content with what you have.", "Hebrews 13:5"),
            ("Better a little with the fear of the Lord than great wealth with turmoil.", "Proverbs 15:16"),
        ],
        "angry": [
            ("Refrain from anger and turn from wrath; do not fret—it leads only to evil.", "Psalm 37:8"),
            ("Do not be quickly provoked in your spirit, for anger resides in the lap of fools.", "Ecclesiastes 7:9"),
            ("Get rid of all bitterness, rage and anger, brawling and slander, along with every form of malice.", "Ephesians 4:31"),
            ("Fools give full vent to their rage, but the wise bring calm in the end.", "Proverbs 29:11"),
        ],
        "confused": [
            ("If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault.", "James 1:5"),
            ("Your word is a lamp for my feet, a light on my path.", "Psalm 119:105"),
            ("For God is not a God of disorder but of peace.", "1 Corinthians 14:33"),
            ("The unfolding of your words gives light; it gives understanding to the simple.", "Psalm 119:130"),
        ],
        "excited": [
            ("Delight yourself in the Lord, and he will give you the desires of your heart.", "Psalm 37:4"),
            ("This is the day the Lord has made; let us rejoice and be glad in it.", "Psalm 118:24"),
            ("Shout for joy to the Lord, all the earth, burst into jubilant song with music.", "Psalm 98:4"),
            ("Let everything that has breath praise the Lord. Praise the Lord!", "Psalm 150:6"),
        ],
        "general": [
            ("For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.", "John 3:16"),
            ("The Lord is my light and my salvation—whom shall I fear?", "Psalm 27:1"),
            ("I am the way and the truth and the life.", "John 14:6"),
            ("Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.", "Joshua 1:9"),
            ("And we know that in all things God works for the good of those who love him.", "Romans 8:28"),
        ]
    ]
    
    /// Get a random verse for a given mood
    static func getVerse(for mood: Mood) -> (text: String, reference: String) {
        let moodVerses = verses[mood.rawValue] ?? verses["general"]!
        return moodVerses.randomElement() ?? verses["general"]!.first!
    }
    
    /// Get a random general verse
    static func getRandomVerse() -> (text: String, reference: String) {
        let allVerses = verses.values.flatMap { $0 }
        return allVerses.randomElement() ?? verses["general"]!.first!
    }
    
    /// Get verse of the day (consistent for the day)
    static func getVerseOfDay() -> (text: String, reference: String) {
        let allVerses = verses.values.flatMap { $0 }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % allVerses.count
        return allVerses[index]
    }
}
