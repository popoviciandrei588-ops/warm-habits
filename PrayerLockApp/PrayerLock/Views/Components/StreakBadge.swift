import SwiftUI

struct StreakBadge: View {
    let streak: Int
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 24
            case .large: return 40
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return PLTypography.labelMedium
            case .medium: return PLTypography.titleMedium
            case .large: return PLTypography.headlineLarge
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return PLSpacing.xs
            case .medium: return PLSpacing.sm
            case .large: return PLSpacing.md
            }
        }
    }
    
    var body: some View {
        HStack(spacing: PLSpacing.xxs) {
            Image(systemName: "flame.fill")
                .font(.system(size: size.iconSize))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "F59E0B"), Color(hex: "EF4444")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("\(streak)")
                .font(size.fontSize)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding / 2)
        .background(Color(hex: "F59E0B").opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakBadge(streak: 7, size: .small)
        StreakBadge(streak: 14, size: .medium)
        StreakBadge(streak: 30, size: .large)
    }
    .padding()
}
