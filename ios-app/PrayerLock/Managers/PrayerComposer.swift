import Foundation

struct PrayerTemplate {
    let mood: String
    let text: String
    let reference: String
}

class PrayerComposer {
    static let shared = PrayerComposer()
    
    private let templates: [PrayerTemplate] = [
        PrayerTemplate(mood: "Anxious", text: "Lord, calm my racing heart. Remind me that You hold tomorrow. I cast my cares on You.", reference: "1 Peter 5:7"),
        PrayerTemplate(mood: "Tired", text: "Father, I am weary. Be my strength. Let me find rest in Your presence and renew my spirit.", reference: "Matthew 11:28"),
        PrayerTemplate(mood: "Grateful", text: "God, thank You for Your faithfulness. My heart overflows with praise for the blessings You've given me.", reference: "Psalm 107:1"),
        PrayerTemplate(mood: "Lonely", text: "Lord, remind me I am never alone. You are with me. Wrap me in Your comfort and love.", reference: "Joshua 1:9"),
        PrayerTemplate(mood: "Distracted", text: "Holy Spirit, focus my mind on what matters. Help me seek You first above all noise.", reference: "Colossians 3:2")
    ]
    
    func generatePrayer(for mood: String) -> PrayerTemplate {
        // Simple offline logic: return a template matching the mood, or a random one if not found.
        // In a real app, this could call an API.
        if let template = templates.first(where: { $0.mood.caseInsensitiveCompare(mood) == .orderedSame }) {
            return template
        }
        return templates.randomElement() ?? templates[0]
    }
    
    func getAllMoods() -> [String] {
        return templates.map { $0.mood }
    }
}
