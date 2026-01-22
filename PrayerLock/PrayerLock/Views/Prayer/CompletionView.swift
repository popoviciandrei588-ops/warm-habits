import SwiftUI

struct CompletionView: View {
    let unlockMinutes: Int
    let onDismiss: () -> Void
    
    @State private var appear = false
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "10B981").opacity(0.3), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(appear ? 1.2 : 0.8)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.5)
            
            // Text content
            VStack(spacing: PLSpacing.md) {
                Text("Prayer Complete")
                    .font(PLTypography.displaySmall)
                    .foregroundColor(.white)
                
                Text("You've unlocked your apps for \(unlockMinutes) minutes")
                    .font(PLTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                // Encouragement
                Text("\"Be still, and know that I am God\"")
                    .font(.system(size: 16, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
                    .italic()
                    .padding(.top, PLSpacing.md)
                
                Text("— Psalm 46:10")
                    .font(PLTypography.labelSmall)
                    .foregroundColor(.white.opacity(0.5))
            }
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            
            Spacer()
            
            // Done button
            Button {
                onDismiss()
            } label: {
                Text("Done")
                    .font(PLTypography.titleMedium)
                    .foregroundColor(Color(hex: "1E3A5F"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PLSpacing.md)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
            }
            .padding(.horizontal, PLSpacing.lg)
            .padding(.bottom, PLSpacing.xl)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
            
            // Haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        CompletionView(unlockMinutes: 10) {}
    }
}
