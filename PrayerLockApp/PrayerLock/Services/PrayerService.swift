import Foundation

class PrayerService {
    
    // MARK: - Prayer Templates
    static func generatePrayer(for mood: MoodType, customNote: String? = nil) -> String {
        let basePrayer = prayerTemplate(for: mood)
        
        if let note = customNote, !note.isEmpty {
            return basePrayer + "\n\n" + customClosing(for: mood)
        }
        
        return basePrayer + "\n\n" + standardClosing
    }
    
    private static func prayerTemplate(for mood: MoodType) -> String {
        switch mood {
        case .anxious:
            return """
            Heavenly Father,
            
            I come before You with a restless heart, weighed down by worry and fear. You know the anxious thoughts that race through my mind. Lord, I surrender these burdens to You.
            
            Your Word tells me not to be anxious about anything, but in everything, through prayer and petition, to present my requests to You. So I lay my worries at Your feet.
            
            Fill me with Your peace that surpasses all understanding. Guard my heart and mind in Christ Jesus. Help me to trust in Your perfect plan, knowing that You hold my future.
            """
            
        case .grateful:
            return """
            Gracious God,
            
            My heart overflows with gratitude for Your countless blessings. You have been so faithful, so loving, so generous in all that You've given me.
            
            Thank You for Your grace that sustains me, Your mercy that renews me each morning, and Your love that never fails. Every good gift comes from You.
            
            Help me to carry this grateful heart into each moment of this day, seeing Your hand in every blessing, both big and small.
            """
            
        case .tempted:
            return """
            Mighty God,
            
            I confess that I am facing temptation. The pull of this world is strong, and I feel my resolve weakening. But I know that You are stronger.
            
            Your Word promises that no temptation has overtaken me except what is common to mankind. And You are faithful—You will not let me be tempted beyond what I can bear.
            
            Provide a way out, Lord. Strengthen my spirit. Fill me with the power of the Holy Spirit to resist and stand firm in Your truth.
            """
            
        case .distracted:
            return """
            Lord of Peace,
            
            My mind is scattered, pulled in a thousand directions. In this noisy world, I struggle to focus on what truly matters—on You.
            
            Quiet my thoughts, Father. Help me to be still and know that You are God. Draw my attention back to Your presence, Your Word, Your will for my life.
            
            Give me a heart that seeks You first, above all the distractions that compete for my attention. Center me in Your love.
            """
            
        case .lonely:
            return """
            God of All Comfort,
            
            In this moment, loneliness weighs heavy on my heart. I long for connection, for companionship, for the feeling that I am truly seen and known.
            
            But You, Lord, promise never to leave me or forsake me. You are the friend who sticks closer than a brother. You see me. You know me. You love me completely.
            
            Wrap me in Your presence. Remind me that I am never truly alone. Fill the empty spaces in my heart with Your unfailing love.
            """
            
        case .angry:
            return """
            Patient Father,
            
            I come to You with anger in my heart. Frustration and hurt have built up inside me, and I need Your help to process these feelings in a healthy way.
            
            Your Word says to be slow to anger, for human anger does not produce the righteousness You desire. Help me to release this anger to You.
            
            Give me Your perspective. Fill me with patience and understanding. Help me to forgive as You have forgiven me. Let Your peace replace my frustration.
            """
            
        case .peaceful:
            return """
            Prince of Peace,
            
            I come to You from a place of calm and rest. In this peaceful moment, I want to simply dwell in Your presence and give You thanks.
            
            Thank You for the gift of peace that comes only from You. Thank You for moments of stillness in the midst of busy days.
            
            Help me to carry this peace with me always. May Your shalom—Your complete peace—flow through me to others I encounter today.
            """
            
        case .tired:
            return """
            Restoring God,
            
            I am weary, Lord. My body is tired, my spirit is drained, and I need Your renewal. You know the burdens I've been carrying.
            
            Your Word invites the weary to come to You, and You will give rest. So I come, just as I am, trusting in Your promise.
            
            Restore my strength like the eagle's. Refresh my soul with Your living water. Grant me the rest that only You can provide.
            """
        }
    }
    
    private static func customClosing(for mood: MoodType) -> String {
        switch mood {
        case .anxious:
            return "Lord, hear my specific concerns that I've shared with You. Take these worries and replace them with Your perfect peace. In Jesus' name, Amen."
        case .grateful:
            return "Thank You for these specific blessings I've named. May my gratitude continue to grow. In Jesus' name, Amen."
        case .tempted:
            return "Help me in this specific struggle, Lord. Give me strength to overcome. In Jesus' name, Amen."
        case .distracted:
            return "Help me to focus on You amidst these distractions. Bring clarity to my mind. In Jesus' name, Amen."
        case .lonely:
            return "In this loneliness, be my constant companion. Fill this void with Your presence. In Jesus' name, Amen."
        case .angry:
            return "Help me to release these specific frustrations to You. Give me Your peace. In Jesus' name, Amen."
        case .peaceful:
            return "Thank You for this peace. Help me to remain in this rest throughout my day. In Jesus' name, Amen."
        case .tired:
            return "Restore me from this specific weariness, Lord. Renew my strength. In Jesus' name, Amen."
        }
    }
    
    private static var standardClosing: String {
        "In Jesus' precious name I pray, Amen."
    }
}

// MARK: - Prayer Prompts
extension PrayerService {
    static func moodPrompt(for mood: MoodType) -> String {
        switch mood {
        case .anxious:
            return "Let go of your worries. God is bigger than your fears."
        case .grateful:
            return "Count your blessings. Give thanks in all circumstances."
        case .tempted:
            return "God provides a way out. You are stronger than this."
        case .distracted:
            return "Be still and know. This moment is for God alone."
        case .lonely:
            return "You are never alone. God is always with you."
        case .angry:
            return "Release your frustration. God's peace can fill you."
        case .peaceful:
            return "Rest in this peace. Let God's presence surround you."
        case .tired:
            return "Come as you are. God will restore your strength."
        }
    }
}
