import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(PLSpacing.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: PLRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: PLRadius.xl)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "1E3A5F"), Color(hex: "0F172A")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        GlassCard {
            VStack(spacing: 12) {
                Text("Prayer Complete")
                    .font(PLTypography.headlineMedium)
                    .foregroundColor(.white)
                
                Text("You've unlocked your apps for 10 minutes")
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
    }
}
