import SwiftUI

struct TimerRing: View {
    let progress: Double
    let timeRemaining: Int
    let isActive: Bool
    
    @State private var breatheScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    
    private let ringGradient = LinearGradient(
        colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6"), Color(hex: "EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            // Breathing background glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "3B82F6").opacity(glowOpacity), .clear],
                        center: .center,
                        startRadius: 80,
                        endRadius: 200
                    )
                )
                .scaleEffect(breatheScale)
            
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .frame(width: 280, height: 280)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(ringGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Inner content
            VStack(spacing: PLSpacing.xs) {
                Text(formattedTime)
                    .font(PLTypography.timerDisplay)
                    .foregroundStyle(ringGradient)
                    .contentTransition(.numericText())
                
                Text(isActive ? "Breathe deeply" : "Ready to pray")
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 320, height: 320)
        .onAppear {
            startBreathingAnimation()
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startBreathingAnimation()
            }
        }
    }
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startBreathingAnimation() {
        guard isActive else { return }
        
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breatheScale = 1.15
            glowOpacity = 0.5
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TimerRing(progress: 0.75, timeRemaining: 45, isActive: true)
    }
}
