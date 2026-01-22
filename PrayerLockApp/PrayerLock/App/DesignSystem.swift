import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary Brand Colors
    static let plPrimary = Color("Primary") // Deep spiritual blue
    static let plSecondary = Color("Secondary") // Warm accent
    static let plAccent = Color("Accent") // Golden highlight
    
    // Semantic Colors
    static let plBackground = Color("Background")
    static let plSurface = Color("Surface")
    static let plSurfaceSecondary = Color("SurfaceSecondary")
    static let plText = Color("Text")
    static let plTextSecondary = Color("TextSecondary")
    static let plTextTertiary = Color("TextTertiary")
    
    // Mood Colors
    static let moodAnxious = Color(hex: "F59E0B")
    static let moodGrateful = Color(hex: "10B981")
    static let moodTempted = Color(hex: "EF4444")
    static let moodDistracted = Color(hex: "8B5CF6")
    static let moodLonely = Color(hex: "6366F1")
    static let moodAngry = Color(hex: "DC2626")
    static let moodPeaceful = Color(hex: "0EA5E9")
    static let moodTired = Color(hex: "64748B")
    
    // Gradients
    static let plGradientStart = Color(hex: "1E3A5F")
    static let plGradientEnd = Color(hex: "0F172A")
    static let timerGradientStart = Color(hex: "3B82F6")
    static let timerGradientEnd = Color(hex: "8B5CF6")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Typography
struct PLTypography {
    // Display - Hero headlines
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 32, weight: .bold, design: .rounded)
    
    // Headlines
    static let headlineLarge = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Titles
    static let titleLarge = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let titleMedium = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let titleSmall = Font.system(size: 14, weight: .semibold, design: .rounded)
    
    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // Labels
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)
    
    // Timer
    static let timerDisplay = Font.system(size: 72, weight: .light, design: .rounded)
    
    // Verse
    static let verseText = Font.system(size: 24, weight: .light, design: .serif)
    static let verseReference = Font.system(size: 14, weight: .medium, design: .serif)
}

// MARK: - Spacing
struct PLSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Radius
struct PLRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

// MARK: - Shadows
extension View {
    func plShadowSmall() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    func plShadowMedium() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    func plShadowLarge() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
    
    func plGlassBackground() -> some View {
        self.background(.ultraThinMaterial)
    }
}

// MARK: - Button Styles
struct PLPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PLTypography.titleMedium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PLSpacing.md)
            .background(
                LinearGradient(
                    colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1) : 0.5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PLSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PLTypography.titleMedium)
            .foregroundColor(Color(hex: "3B82F6"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, PLSpacing.md)
            .background(Color(hex: "3B82F6").opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PLGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PLTypography.titleSmall)
            .foregroundColor(.secondary)
            .padding(.vertical, PLSpacing.sm)
            .padding(.horizontal, PLSpacing.md)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == PLPrimaryButtonStyle {
    static var plPrimary: PLPrimaryButtonStyle { PLPrimaryButtonStyle() }
}

extension ButtonStyle where Self == PLSecondaryButtonStyle {
    static var plSecondary: PLSecondaryButtonStyle { PLSecondaryButtonStyle() }
}

extension ButtonStyle where Self == PLGhostButtonStyle {
    static var plGhost: PLGhostButtonStyle { PLGhostButtonStyle() }
}

// MARK: - Card Modifier
struct PLCardModifier: ViewModifier {
    var padding: CGFloat = PLSpacing.md
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
            .plShadowSmall()
    }
}

extension View {
    func plCard(padding: CGFloat = PLSpacing.md) -> some View {
        modifier(PLCardModifier(padding: padding))
    }
}

// MARK: - Animations
extension Animation {
    static let plSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let plEaseOut = Animation.easeOut(duration: 0.3)
    static let plBreathing = Animation.easeInOut(duration: 4).repeatForever(autoreverses: true)
}
