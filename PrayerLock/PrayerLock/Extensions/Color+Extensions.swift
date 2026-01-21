import SwiftUI

extension Color {
    // MARK: - App Colors
    static let prayerPrimary = Color.indigo
    static let prayerSecondary = Color.purple
    static let prayerAccent = Color.orange
    static let prayerSuccess = Color.green
    static let prayerWarning = Color.yellow
    static let prayerError = Color.red
    
    // MARK: - Background Colors
    static let prayerBackground = Color(red: 0.08, green: 0.08, blue: 0.15)
    static let prayerBackgroundSecondary = Color(red: 0.12, green: 0.1, blue: 0.2)
    static let prayerCardBackground = Color.white.opacity(0.05)
    
    // MARK: - Gradient Helpers
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [.indigo, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [prayerBackground, prayerBackgroundSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Mood Colors
    static func moodColor(for mood: Mood) -> Color {
        switch mood.color {
        case "green": return .green
        case "orange": return .orange
        case "yellow": return .yellow
        case "blue": return .blue
        case "red": return .red
        case "teal": return .teal
        case "purple": return .purple
        case "gray": return .gray
        default: return .indigo
        }
    }
    
    // MARK: - Hex Initialization
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
