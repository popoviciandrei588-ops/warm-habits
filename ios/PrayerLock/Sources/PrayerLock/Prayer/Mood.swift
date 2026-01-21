import Foundation

enum Mood: String, CaseIterable, Identifiable, Codable {
    case anxious
    case stressed
    case distracted
    case tired
    case lonely
    case tempted
    case grateful
    case hopeful
    case sad
    case angry

    var id: String { rawValue }

    var title: String {
        switch self {
        case .anxious: return "Anxious"
        case .stressed: return "Stressed"
        case .distracted: return "Distracted"
        case .tired: return "Tired"
        case .lonely: return "Lonely"
        case .tempted: return "Tempted"
        case .grateful: return "Grateful"
        case .hopeful: return "Hopeful"
        case .sad: return "Sad"
        case .angry: return "Angry"
        }
    }

    var subtitle: String {
        switch self {
        case .anxious: return "Needing peace and steadiness"
        case .stressed: return "Overwhelmed or pressured"
        case .distracted: return "Scattered attention and restlessness"
        case .tired: return "Worn down and low on strength"
        case .lonely: return "Longing for closeness and comfort"
        case .tempted: return "Pulled toward habits you don’t want"
        case .grateful: return "Wanting to thank God"
        case .hopeful: return "Believing for good things ahead"
        case .sad: return "Heavy-hearted or grieving"
        case .angry: return "Frustrated or hurt"
        }
    }
}

