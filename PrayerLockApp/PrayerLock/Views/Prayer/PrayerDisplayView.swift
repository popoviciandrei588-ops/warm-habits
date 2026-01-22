import SwiftUI

struct PrayerDisplayView: View {
    let prayer: String
    let mood: MoodType?
    let onContinue: () -> Void
    
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: PLSpacing.lg) {
            Spacer()
            
            // Mood indicator
            if let mood = mood {
                HStack(spacing: PLSpacing.xs) {
                    Image(systemName: mood.icon)
                        .font(.system(size: 14))
                    Text(PrayerService.moodPrompt(for: mood))
                        .font(PLTypography.labelMedium)
                }
                .foregroundColor(Color(hex: mood.color))
                .padding(.horizontal, PLSpacing.md)
                .padding(.vertical, PLSpacing.xs)
                .background(Color(hex: mood.color).opacity(0.2))
                .clipShape(Capsule())
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            }
            
            // Header
            Text("Your Prayer")
                .font(PLTypography.headlineLarge)
                .foregroundColor(.white)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            // Prayer text
            ScrollView {
                Text(prayer)
                    .font(.system(size: 18, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, PLSpacing.lg)
            }
            .frame(maxHeight: 350)
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black, location: 0.03),
                        .init(color: .black, location: 0.97),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            
            Spacer()
            
            // Continue button
            VStack(spacing: PLSpacing.sm) {
                Text("Read through this prayer, then continue")
                    .font(PLTypography.bodySmall)
                    .foregroundColor(.white.opacity(0.6))
                
                Button {
                    onContinue()
                } label: {
                    HStack {
                        Text("Begin Timer")
                        Image(systemName: "arrow.right")
                    }
                    .font(PLTypography.titleMedium)
                    .foregroundColor(Color(hex: "1E3A5F"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PLSpacing.md)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
                }
            }
            .padding(.horizontal, PLSpacing.lg)
            .padding(.bottom, PLSpacing.xl)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        PrayerDisplayView(
            prayer: PrayerService.generatePrayer(for: .anxious),
            mood: .anxious
        ) {}
    }
}
