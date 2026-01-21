import SwiftUI

/// The main prayer timer view - the "lock" screen that shows during prayer
struct PrayerTimerView: View {
    let mood: Mood
    let customText: String?
    
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var timeRemaining: Int = 60
    @State private var totalTime: Int = 60
    @State private var isTimerRunning = false
    @State private var showCompletion = false
    @State private var composedPrayer: ComposedPrayer?
    @State private var animationProgress: CGFloat = 0
    @State private var breatheScale: CGFloat = 1.0
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let prayerComposer = PrayerComposer.shared
    
    var body: some View {
        ZStack {
            // Animated background
            animatedBackground
            
            VStack(spacing: 0) {
                // Top section with exit hint
                topBar
                
                Spacer()
                
                // Prayer content
                prayerContent
                
                Spacer()
                
                // Timer circle
                timerCircle
                
                Spacer()
                
                // Bottom info
                bottomInfo
            }
            .padding()
        }
        .onAppear {
            setupTimer()
            generatePrayer()
            startBreathingAnimation()
        }
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 1
                animationProgress = CGFloat(totalTime - timeRemaining) / CGFloat(totalTime)
            } else if timeRemaining == 0 {
                completePrayer()
            }
        }
        .fullScreenCover(isPresented: $showCompletion) {
            PrayerCompletedView(
                mood: mood,
                duration: totalTime,
                prayer: composedPrayer
            )
        }
    }
    
    // MARK: - Animated Background
    private var animatedBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.15),
                    Color(red: 0.12, green: 0.1, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle animated circles
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.indigo.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)
                .scaleEffect(breatheScale)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)
                .scaleEffect(1.1 - (breatheScale - 1.0))
        }
    }
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            // Mood indicator
            HStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.title3)
                Text(mood.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            // Exit warning
            Text("Stay to unlock")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Prayer Content
    private var prayerContent: some View {
        VStack(spacing: 20) {
            // Prayer header
            Text("🙏")
                .font(.system(size: 44))
            
            Text("Time to Pray")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Prayer text
            if let prayer = composedPrayer {
                ScrollView {
                    VStack(spacing: 16) {
                        Text(prayer.text)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal)
                        
                        if let reference = prayer.bibleReference {
                            Text("📖 \(reference)")
                                .font(.callout)
                                .fontWeight(.medium)
                                .foregroundColor(.indigo.opacity(0.8))
                        }
                    }
                }
                .frame(maxHeight: 200)
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    // MARK: - Timer Circle
    private var timerCircle: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 12)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animationProgress)
                .stroke(
                    LinearGradient(
                        colors: [.indigo, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: animationProgress)
            
            // Time display
            VStack(spacing: 4) {
                Text(formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: timeRemaining)
                
                Text("remaining")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    // MARK: - Bottom Info
    private var bottomInfo: some View {
        VStack(spacing: 8) {
            Text("Focus on connecting with God")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
            
            Text("Take this moment to breathe, reflect, and pray")
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Helper Methods
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func setupTimer() {
        // Get duration from user settings or use default
        // For now, using default 60 seconds
        totalTime = 60
        timeRemaining = totalTime
        isTimerRunning = true
        
        // Start blocking apps
        screenTimeManager.startBlocking()
    }
    
    private func generatePrayer() {
        composedPrayer = prayerComposer.generatePrayer(for: mood, customText: customText)
    }
    
    private func startBreathingAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 4)
                .repeatForever(autoreverses: true)
        ) {
            breatheScale = 1.15
        }
    }
    
    private func completePrayer() {
        isTimerRunning = false
        
        // Stop blocking apps
        screenTimeManager.stopBlocking()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show completion
        showCompletion = true
    }
}

// MARK: - Preview
#Preview {
    PrayerTimerView(mood: .anxious, customText: "Work deadline")
}
