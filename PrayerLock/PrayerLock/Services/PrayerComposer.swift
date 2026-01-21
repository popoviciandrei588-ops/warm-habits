import Foundation

/// Service responsible for generating personalized prayers based on mood/feeling
/// Supports both offline templates and stubbed remote API for future integration
final class PrayerComposer {
    
    // MARK: - Singleton
    static let shared = PrayerComposer()
    
    // MARK: - Private Properties
    private let prayerTemplates: [Mood: [PrayerTemplate]]
    
    // MARK: - Initialization
    private init() {
        self.prayerTemplates = Self.loadTemplates()
    }
    
    // MARK: - Public Methods
    
    /// Generate a prayer for the given mood
    /// - Parameters:
    ///   - mood: The user's selected mood/feeling
    ///   - customText: Optional custom text from user
    /// - Returns: A composed prayer with optional Bible reference
    func generatePrayer(for mood: Mood, customText: String? = nil) -> ComposedPrayer {
        // Get templates for the mood, or use general templates
        let templates = prayerTemplates[mood] ?? prayerTemplates[.grateful] ?? []
        
        guard let template = templates.randomElement() else {
            return defaultPrayer(for: mood)
        }
        
        // Build the prayer text
        var prayerText = template.opening
        
        // Add mood-specific middle section
        prayerText += " " + template.moodSpecificContent
        
        // If user provided custom text, incorporate it
        if let custom = customText, !custom.isEmpty {
            prayerText += " I specifically bring before You: \(custom)."
        }
        
        // Add closing
        prayerText += " " + template.closing
        
        return ComposedPrayer(
            text: prayerText,
            bibleReference: template.bibleReference,
            mood: mood,
            template: template
        )
    }
    
    /// Generate a quick prayer (shorter version)
    func generateQuickPrayer(for mood: Mood) -> ComposedPrayer {
        let quickTemplates: [Mood: String] = [
            .grateful: "Lord, I thank You for Your blessings today. Help me see Your hand in all things. Amen.",
            .anxious: "Father, calm my anxious heart. I trust in Your perfect plan. Amen.",
            .joyful: "God, thank You for this joy! May it overflow to others. Amen.",
            .sad: "Lord, comfort me in my sadness. You are near to the brokenhearted. Amen.",
            .stressed: "Jesus, I give You my stress. Grant me Your peace. Amen.",
            .hopeful: "Father, thank You for hope. Help me trust Your promises. Amen.",
            .frustrated: "Lord, help me release this frustration to You. Give me patience. Amen.",
            .peaceful: "God, thank You for this peace. May it guard my heart always. Amen.",
            .overwhelmed: "Father, I'm overwhelmed. Be my refuge and strength. Amen.",
            .lonely: "Lord, You are with me always. Help me feel Your presence. Amen.",
            .thankful: "God, my heart overflows with gratitude. Thank You for everything. Amen.",
            .fearful: "Father, I give You my fears. You have not given me a spirit of fear. Amen.",
            .content: "Lord, thank You for contentment. Help me find joy in You alone. Amen.",
            .angry: "God, take my anger and replace it with Your peace. Amen.",
            .confused: "Father, guide my steps. Your Word is a lamp unto my feet. Amen.",
            .excited: "Lord, thank You for this excitement! May I use this energy for Your glory. Amen."
        ]
        
        let text = quickTemplates[mood] ?? "Lord, I come before You with an open heart. Guide me today. Amen."
        
        return ComposedPrayer(
            text: text,
            bibleReference: nil,
            mood: mood,
            template: nil
        )
    }
    
    /// Stub for remote prayer generation (future API integration)
    func generatePrayerRemote(for mood: Mood, customText: String?) async -> ComposedPrayer {
        // TODO: Implement remote API call here
        // For now, fall back to local generation
        // Example API endpoint: POST /api/prayers/generate
        // Request body: { "mood": "anxious", "customText": "work deadline" }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return generatePrayer(for: mood, customText: customText)
    }
    
    // MARK: - Private Methods
    
    private func defaultPrayer(for mood: Mood) -> ComposedPrayer {
        let text = """
        Heavenly Father, I come before You with a \(mood.displayName.lowercased()) heart. \
        I know that You see me and You care for me deeply. \
        Help me to draw closer to You in this moment and throughout my day. \
        Thank You for Your unfailing love and constant presence. \
        In Jesus' name, Amen.
        """
        
        return ComposedPrayer(
            text: text,
            bibleReference: "Psalm 139:1-2",
            mood: mood,
            template: nil
        )
    }
    
    // MARK: - Template Loading
    
    private static func loadTemplates() -> [Mood: [PrayerTemplate]] {
        var templates: [Mood: [PrayerTemplate]] = [:]
        
        // Grateful prayers
        templates[.grateful] = [
            PrayerTemplate(
                opening: "Heavenly Father, I come before You with a heart full of gratitude.",
                moodSpecificContent: "Thank You for the countless blessings You pour into my life each day. Help me to never take Your goodness for granted. Open my eyes to see Your hand at work in every situation.",
                closing: "May my life be a reflection of thanksgiving to You. In Jesus' precious name, Amen.",
                bibleReference: "Psalm 100:4-5"
            ),
            PrayerTemplate(
                opening: "Lord God, my heart overflows with thankfulness today.",
                moodSpecificContent: "You have been so faithful, even when I haven't deserved it. Thank You for Your grace, Your mercy, and Your love that never fails. Help me to cultivate a spirit of gratitude in all circumstances.",
                closing: "I praise You for who You are and all You've done. Amen.",
                bibleReference: "1 Thessalonians 5:18"
            )
        ]
        
        // Anxious prayers
        templates[.anxious] = [
            PrayerTemplate(
                opening: "Lord Jesus, I come to You feeling anxious and worried.",
                moodSpecificContent: "My mind is racing with concerns about things I cannot control. I know You tell me not to be anxious, but to bring everything to You in prayer. So I lay my worries at Your feet right now. Replace my anxiety with Your perfect peace that surpasses all understanding.",
                closing: "Guard my heart and mind in Christ Jesus. I trust in You. Amen.",
                bibleReference: "Philippians 4:6-7"
            ),
            PrayerTemplate(
                opening: "Father, my heart is troubled and my thoughts are scattered.",
                moodSpecificContent: "The weight of worry feels heavy on my shoulders. But I remember that You invite me to cast all my anxieties on You because You care for me. Help me to release these burdens and rest in Your sovereign care.",
                closing: "Calm the storm within me and anchor my soul in Your faithfulness. Amen.",
                bibleReference: "1 Peter 5:7"
            )
        ]
        
        // Joyful prayers
        templates[.joyful] = [
            PrayerTemplate(
                opening: "Hallelujah! Lord, my heart is filled with joy!",
                moodSpecificContent: "I celebrate Your goodness and the blessings You've placed in my life. This joy is not dependent on circumstances but flows from knowing You. Help me to share this joy with others today.",
                closing: "May the joy of the Lord be my strength now and always. Amen.",
                bibleReference: "Nehemiah 8:10"
            ),
            PrayerTemplate(
                opening: "Father God, I come before You with a joyful heart!",
                moodSpecificContent: "Thank You for the gift of joy that comes from Your presence. Help me to rejoice always, as Your Word commands, knowing that You are working all things together for good.",
                closing: "Let my joy be contagious and point others to You. In Jesus' name, Amen.",
                bibleReference: "Philippians 4:4"
            )
        ]
        
        // Sad prayers
        templates[.sad] = [
            PrayerTemplate(
                opening: "Lord, I come to You with a heavy heart.",
                moodSpecificContent: "Sadness has settled over me, and I feel the weight of it. But I know that You are close to the brokenhearted. You collect every tear and hold me in Your loving arms. Help me to feel Your comfort today.",
                closing: "Heal my heart and restore my joy in Your perfect timing. Amen.",
                bibleReference: "Psalm 34:18"
            ),
            PrayerTemplate(
                opening: "Father, my heart is aching and my spirit is low.",
                moodSpecificContent: "In this moment of sadness, I cling to Your promises. You have said that weeping may last for a night, but joy comes in the morning. Help me to trust that brighter days are ahead.",
                closing: "Be my comfort and my hope in this difficult time. Amen.",
                bibleReference: "Psalm 30:5"
            )
        ]
        
        // Stressed prayers
        templates[.stressed] = [
            PrayerTemplate(
                opening: "Lord Jesus, I am overwhelmed with stress and pressure.",
                moodSpecificContent: "The demands of life feel like too much to bear. You said to come to You when I am weary and burdened, and You would give me rest. I come to You now, seeking the rest that only You can provide.",
                closing: "Take my yoke upon You, for Your burden is light. Amen.",
                bibleReference: "Matthew 11:28-30"
            ),
            PrayerTemplate(
                opening: "Father, the stress of life is weighing heavily on me.",
                moodSpecificContent: "Help me to remember that I am not alone in carrying these burdens. You are my ever-present help in times of trouble. Give me wisdom to know what I can change and peace to accept what I cannot.",
                closing: "Be my refuge and strength today and always. Amen.",
                bibleReference: "Psalm 46:1"
            )
        ]
        
        // Hopeful prayers
        templates[.hopeful] = [
            PrayerTemplate(
                opening: "Lord, my heart is filled with hope today!",
                moodSpecificContent: "I trust in Your promises and Your perfect plan for my life. You have plans to prosper me and give me a future filled with hope. Help me to hold onto this hope even when circumstances seem uncertain.",
                closing: "Fill me with joy and peace as I trust in You. Amen.",
                bibleReference: "Jeremiah 29:11"
            ),
            PrayerTemplate(
                opening: "Father, thank You for the gift of hope.",
                moodSpecificContent: "In a world filled with uncertainty, You are my anchor. Your promises are sure, and Your faithfulness never wavers. Help me to be a beacon of hope to others who are struggling.",
                closing: "May I overflow with hope by the power of the Holy Spirit. Amen.",
                bibleReference: "Romans 15:13"
            )
        ]
        
        // Frustrated prayers
        templates[.frustrated] = [
            PrayerTemplate(
                opening: "Lord, I come to You feeling frustrated and impatient.",
                moodSpecificContent: "Things are not going as I planned, and I'm struggling with these feelings. Help me to release my frustration to You and trust in Your perfect timing. Give me patience and help me to respond with grace.",
                closing: "Transform my frustration into faith and my impatience into peace. Amen.",
                bibleReference: "James 1:19-20"
            ),
            PrayerTemplate(
                opening: "Father, I lay my frustrations at Your feet.",
                moodSpecificContent: "I know that anger does not produce the righteousness You desire. Help me to be slow to anger and quick to forgive. Replace my frustration with Your gentle spirit.",
                closing: "Give me the patience and peace that only comes from You. Amen.",
                bibleReference: "Proverbs 15:1"
            )
        ]
        
        // Peaceful prayers
        templates[.peaceful] = [
            PrayerTemplate(
                opening: "Lord, thank You for this peace that fills my heart.",
                moodSpecificContent: "In a world of chaos and noise, You have given me a calm spirit. Help me to guard this peace and share it with others. May Your peace continue to rule in my heart.",
                closing: "Keep me in perfect peace as my mind is fixed on You. Amen.",
                bibleReference: "Isaiah 26:3"
            ),
            PrayerTemplate(
                opening: "Father, I rest in Your perfect peace today.",
                moodSpecificContent: "Thank You for the peace that transcends all understanding. Help me to remain in this state of rest, trusting fully in Your sovereignty over every area of my life.",
                closing: "May Your peace guard my heart and mind always. Amen.",
                bibleReference: "Philippians 4:7"
            )
        ]
        
        // Overwhelmed prayers
        templates[.overwhelmed] = [
            PrayerTemplate(
                opening: "Lord, I am feeling completely overwhelmed right now.",
                moodSpecificContent: "Life's demands seem impossible to meet, and I don't know where to turn. But I know that when I am overwhelmed, You alone know the way I should go. Lead me, guide me, and give me clarity.",
                closing: "Be my rock and my fortress. I put my trust in You. Amen.",
                bibleReference: "Psalm 142:3"
            ),
            PrayerTemplate(
                opening: "Father, the waves of life are crashing over me.",
                moodSpecificContent: "I feel like I'm drowning in responsibilities and worries. But You are the God who calms the storms. Speak peace over my chaos and help me to focus on one step at a time.",
                closing: "You are my refuge and strength, an ever-present help. Amen.",
                bibleReference: "Psalm 46:1-2"
            )
        ]
        
        // Lonely prayers
        templates[.lonely] = [
            PrayerTemplate(
                opening: "Lord, I feel alone right now, and it hurts.",
                moodSpecificContent: "In this loneliness, help me to remember that You are always with me. You promised never to leave me or forsake me. Draw near to me as I draw near to You. Fill this emptiness with Your presence.",
                closing: "Be my companion and my closest friend. Amen.",
                bibleReference: "Hebrews 13:5"
            ),
            PrayerTemplate(
                opening: "Father, loneliness has crept into my heart.",
                moodSpecificContent: "I long for connection and companionship. Thank You that even when I feel alone, You are there. Help me to feel Your presence in a tangible way today.",
                closing: "You set the lonely in families. Connect me with Your love. Amen.",
                bibleReference: "Psalm 68:6"
            )
        ]
        
        // Thankful prayers
        templates[.thankful] = [
            PrayerTemplate(
                opening: "Gracious God, my soul magnifies Your name!",
                moodSpecificContent: "I cannot help but thank You for all the ways You've blessed me. Every good and perfect gift comes from above, from You, the Father of lights. Help me to live each day with a heart of thanksgiving.",
                closing: "Receive my gratitude as an offering of praise. Amen.",
                bibleReference: "James 1:17"
            ),
            PrayerTemplate(
                opening: "Lord, I pause to thank You for Your faithfulness.",
                moodSpecificContent: "When I look back at my life, I see Your hand guiding me every step of the way. Thank You for provision, protection, and most of all, Your salvation through Christ.",
                closing: "May thanksgiving flow from my lips continually. Amen.",
                bibleReference: "Psalm 103:2"
            )
        ]
        
        // Fearful prayers
        templates[.fearful] = [
            PrayerTemplate(
                opening: "Lord, fear has gripped my heart.",
                moodSpecificContent: "I feel afraid of what lies ahead. But Your Word says You have not given me a spirit of fear, but of power, love, and a sound mind. Help me to claim that truth right now. Replace my fear with faith.",
                closing: "I will trust in You and not be afraid. Amen.",
                bibleReference: "2 Timothy 1:7"
            ),
            PrayerTemplate(
                opening: "Father, I bring my fears to You.",
                moodSpecificContent: "When I am afraid, I will put my trust in You. Help me to remember that You are bigger than anything I face. Your perfect love casts out fear.",
                closing: "Be my shield and my protector. I trust in Your care. Amen.",
                bibleReference: "Psalm 56:3"
            )
        ]
        
        // Content prayers
        templates[.content] = [
            PrayerTemplate(
                opening: "Lord, thank You for this sense of contentment.",
                moodSpecificContent: "In a world that always wants more, You have taught me to be satisfied in You alone. Whether I have plenty or little, help me to find my joy in Your presence, not in possessions.",
                closing: "You are enough. You are more than enough. Amen.",
                bibleReference: "Philippians 4:11-12"
            ),
            PrayerTemplate(
                opening: "Father, I rest in the contentment You've given me.",
                moodSpecificContent: "Thank You that godliness with contentment is great gain. Help me to treasure what truly matters: relationship with You and love for others.",
                closing: "Keep my heart content in Your love always. Amen.",
                bibleReference: "1 Timothy 6:6"
            )
        ]
        
        // Angry prayers
        templates[.angry] = [
            PrayerTemplate(
                opening: "Lord, I come to You with anger in my heart.",
                moodSpecificContent: "I know that in my anger, I should not sin. Help me to process these feelings in a healthy way. Take this anger and transform it into righteous action or release it completely.",
                closing: "Give me Your peace and help me to forgive. Amen.",
                bibleReference: "Ephesians 4:26"
            ),
            PrayerTemplate(
                opening: "Father, I'm struggling with angry feelings.",
                moodSpecificContent: "Before I do or say something I'll regret, I come to You. Cool the fire in my heart with Your gentle Spirit. Help me to be slow to anger, just as You are slow to anger with me.",
                closing: "Replace my anger with love and understanding. Amen.",
                bibleReference: "James 1:19"
            )
        ]
        
        // Confused prayers
        templates[.confused] = [
            PrayerTemplate(
                opening: "Lord, I'm feeling confused and uncertain.",
                moodSpecificContent: "I don't know which way to turn or what decision to make. Your Word says that if I lack wisdom, I should ask You, and You will give it generously. I'm asking now. Guide my thoughts and my steps.",
                closing: "Be the lamp to my feet and light to my path. Amen.",
                bibleReference: "James 1:5"
            ),
            PrayerTemplate(
                opening: "Father, clarity seems to escape me.",
                moodSpecificContent: "In this fog of confusion, be my guide. You are not a God of disorder but of peace. Help me to trust that You will make my path straight as I acknowledge You in all my ways.",
                closing: "Lead me in the way everlasting. Amen.",
                bibleReference: "Proverbs 3:5-6"
            )
        ]
        
        // Excited prayers
        templates[.excited] = [
            PrayerTemplate(
                opening: "Lord, I can barely contain my excitement!",
                moodSpecificContent: "Thank You for this burst of joy and anticipation! Help me to channel this energy toward things that honor You. Let my excitement be contagious and draw others to Your goodness.",
                closing: "May I always find reasons to be excited about Your works! Amen.",
                bibleReference: "Psalm 118:24"
            ),
            PrayerTemplate(
                opening: "Father, my heart is racing with excitement!",
                moodSpecificContent: "Whatever has sparked this feeling, I offer it to You. Help me to celebrate the good gifts You give while keeping You at the center of my joy.",
                closing: "Let me shout for joy and be glad in You! Amen.",
                bibleReference: "Psalm 98:4"
            )
        ]
        
        return templates
    }
}

// MARK: - Supporting Types

/// A template for generating prayers
struct PrayerTemplate {
    let opening: String
    let moodSpecificContent: String
    let closing: String
    let bibleReference: String?
}

/// A composed prayer ready to be displayed
struct ComposedPrayer {
    let text: String
    let bibleReference: String?
    let mood: Mood
    let template: PrayerTemplate?
    
    /// The complete prayer with reference
    var fullText: String {
        if let reference = bibleReference {
            return "\(text)\n\n📖 \(reference)"
        }
        return text
    }
    
    /// Word count of the prayer
    var wordCount: Int {
        text.split(separator: " ").count
    }
    
    /// Estimated reading time in seconds (average 200 words per minute)
    var estimatedReadingTime: Int {
        max(15, Int(Double(wordCount) / 200.0 * 60.0))
    }
}
