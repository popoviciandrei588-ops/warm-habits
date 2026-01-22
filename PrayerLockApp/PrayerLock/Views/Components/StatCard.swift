import SwiftUI

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    
    init(
        icon: String,
        title: String,
        value: String,
        subtitle: String? = nil,
        color: Color = Color(hex: "3B82F6")
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PLSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: PLSpacing.xxxs) {
                Text(value)
                    .font(PLTypography.headlineLarge)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(PLTypography.bodySmall)
                    .foregroundColor(.secondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PLTypography.labelSmall)
                        .foregroundColor(.tertiary)
                }
            }
        }
        .padding(PLSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
    }
}

#Preview {
    HStack {
        StatCard(
            icon: "clock.fill",
            title: "Minutes Prayed",
            value: "247",
            subtitle: "+12 this week"
        )
        
        StatCard(
            icon: "calendar",
            title: "Sessions",
            value: "52",
            color: Color(hex: "10B981")
        )
    }
    .padding()
}
