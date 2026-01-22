import SwiftUI

struct MoodChip: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PLSpacing.xs) {
                Image(systemName: mood.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(mood.rawValue)
                    .font(PLTypography.labelLarge)
            }
            .foregroundColor(isSelected ? .white : Color(hex: mood.color))
            .padding(.horizontal, PLSpacing.md)
            .padding(.vertical, PLSpacing.sm)
            .background(
                Group {
                    if isSelected {
                        Color(hex: mood.color)
                    } else {
                        Color(hex: mood.color).opacity(0.15)
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(hex: mood.color).opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.plSpring, value: isSelected)
    }
}

#Preview {
    VStack(spacing: 20) {
        MoodChip(mood: .anxious, isSelected: true) {}
        MoodChip(mood: .grateful, isSelected: false) {}
        MoodChip(mood: .peaceful, isSelected: false) {}
    }
    .padding()
}
