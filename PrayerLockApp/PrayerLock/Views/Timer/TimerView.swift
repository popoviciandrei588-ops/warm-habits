import SwiftUI

struct TimerView: View {
    let duration: Int
    let onComplete: () -> Void
    
    @State private var timeRemaining: Int
    @State private var isActive = false
    @State private var timer: Timer?
    @State private var appear = false
    @State private var showStartButton = true
    
    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            // Timer ring
            TimerRing(
                progress: progress,
                timeRemaining: timeRemaining,
                isActive: isActive
            )
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.8)
            
            // Breathing instruction
            if isActive {
                Text("Breathe deeply and pray")
                    .font(PLTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .transition(.opacity)
            }
            
            Spacer()
            
            // Start/Complete button
            if showStartButton && !isActive {
                Button {
                    startTimer()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Prayer")
                    }
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
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appear = true
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var progress: Double {
        1 - (Double(timeRemaining) / Double(duration))
    }
    
    private func startTimer() {
        withAnimation(.plSpring) {
            isActive = true
            showStartButton = false
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                withAnimation {
                    timeRemaining -= 1
                }
            } else {
                timer?.invalidate()
                completeTimer()
            }
        }
    }
    
    private func completeTimer() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onComplete()
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        TimerView(duration: 60) {}
    }
}
