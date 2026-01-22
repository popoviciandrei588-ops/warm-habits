import SwiftUI

struct PrayerSessionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    @State private var timeRemaining: Int = 60
    @State private var isTimerRunning = false
    @State private var hasCompleted = false
    @State private var showingCompletion = false
    @State private var breatheScale: CGFloat = 1.0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        1.0 - Double(timeRemaining) / Double(appState.settings.prayerDurationSeconds)
    }
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedGradientBackground()
            
            if showingCompletion {
                CompletionView(onDismiss: {
                    appState.completePrayer()
                    screenTimeManager.temporarilyDisableBlocking(for: 3600)
                })
            } else {
                VStack(spacing: 25) {
                    // Header
                    PrayerHeader()
                    
                    Spacer()
                    
                    // Mood indicator
                    if let prayer = appState.currentPrayer {
                        MoodIndicator(mood: prayer.mood)
                    }
                    
                    // Timer based on style
                    timerView
                        .onTapGesture {
                            if !isTimerRunning {
                                startTimer()
                            }
                        }
                    
                    // Breathing guide
                    if isTimerRunning {
                        BreathingGuide(scale: $breatheScale)
                    }
                    
                    // Prayer text
                    if let prayer = appState.currentPrayer {
                        PrayerTextCard(prayer: prayer)
                    }
                    
                    Spacer()
                    
                    // Bottom controls
                    BottomControls(isTimerRunning: isTimerRunning) {
                        appState.getNewPrayer()
                    }
                }
                .padding()
            }
            
            // Show confetti on completion
            if appState.showConfetti {
                ConfettiView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            appState.showConfetti = false
                        }
                    }
            }
            
            // Level up modal
            if appState.showLevelUp {
                LevelUpModal(level: appState.newLevel) {
                    appState.showLevelUp = false
                }
            }
            
            // Achievement toast
            if appState.showAchievement, let achievement = appState.newAchievement {
                AchievementToast(achievement: achievement)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            appState.showAchievement = false
                        }
                    }
            }
        }
        .onAppear {
            timeRemaining = appState.settings.prayerDurationSeconds
        }
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 && isTimerRunning {
                completeTimer()
            }
        }
    }
    
    @ViewBuilder
    var timerView: some View {
        switch appState.settings.timerStyle {
        case .circular:
            CircularTimer(timeRemaining: timeRemaining, progress: progress, isRunning: isTimerRunning)
        case .digital:
            DigitalTimer(timeRemaining: timeRemaining, progress: progress, isRunning: isTimerRunning)
        case .minimal:
            MinimalTimer(timeRemaining: timeRemaining, progress: progress, isRunning: isTimerRunning)
        case .nature:
            NatureTimer(timeRemaining: timeRemaining, progress: progress, isRunning: isTimerRunning)
        }
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)"
    }
    
    func startTimer() {
        isTimerRunning = true
        startBreathingAnimation()
    }
    
    func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            breatheScale = 1.2
        }
    }
    
    func completeTimer() {
        isTimerRunning = false
        hasCompleted = true
        withAnimation(.spring()) {
            showingCompletion = true
        }
    }
}

// MARK: - Prayer Header
struct PrayerHeader: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                appState.showPrayerScreen = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.ultraThinMaterial)
            }
        }
    }
}

// MARK: - Mood Indicator
struct MoodIndicator: View {
    let mood: PrayerMood
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: mood.icon)
            Text(mood.rawValue)
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(appState.settings.theme.gradient)
        .cornerRadius(25)
    }
}

// MARK: - Timer Styles

struct CircularTimer: View {
    let timeRemaining: Int
    let progress: Double
    let isRunning: Bool
    @EnvironmentObject var appState: AppState
    @State private var pulseAnimation = false
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)"
    }
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(appState.settings.theme.primaryColor.opacity(0.1))
                .frame(width: 240, height: 240)
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
            
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                .frame(width: 200, height: 200)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    appState.settings.theme.gradient,
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            // Inner content
            VStack(spacing: 8) {
                Text(timeString)
                    .font(.system(size: 56, weight: .thin, design: .rounded))
                
                Text(isRunning ? "Breathe..." : "Tap to begin")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            if isRunning {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
        .onChange(of: isRunning) { _, running in
            if running {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
    }
}

struct DigitalTimer: View {
    let timeRemaining: Int
    let progress: Double
    let isRunning: Bool
    @EnvironmentObject var appState: AppState
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(timeString)
                .font(.system(size: 80, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(appState.settings.theme.gradient)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(appState.settings.theme.gradient)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.linear(duration: 1), value: progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 40)
            
            Text(isRunning ? "In Prayer" : "Tap to begin")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
}

struct MinimalTimer: View {
    let timeRemaining: Int
    let progress: Double
    let isRunning: Bool
    @EnvironmentObject var appState: AppState
    @State private var opacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            Text("\(timeRemaining)")
                .font(.system(size: 120, weight: .ultraLight, design: .rounded))
                .foregroundStyle(appState.settings.theme.gradient)
                .opacity(opacity)
            
            Text(isRunning ? "seconds of peace" : "tap to begin")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(height: 220)
        .onAppear {
            if isRunning {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    opacity = 0.7
                }
            }
        }
    }
}

struct NatureTimer: View {
    let timeRemaining: Int
    let progress: Double
    let isRunning: Bool
    @EnvironmentObject var appState: AppState
    @State private var leafRotation: Double = 0
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)"
    }
    
    var body: some View {
        ZStack {
            // Leaves circle
            ForEach(0..<12) { i in
                Image(systemName: "leaf.fill")
                    .font(.title)
                    .foregroundColor(Double(i) / 12.0 <= progress ? appState.settings.theme.primaryColor : Color.gray.opacity(0.3))
                    .rotationEffect(.degrees(Double(i) * 30 + leafRotation))
                    .offset(y: -100)
                    .rotationEffect(.degrees(Double(i) * 30))
            }
            
            VStack(spacing: 8) {
                Image(systemName: "tree.fill")
                    .font(.title)
                    .foregroundStyle(appState.settings.theme.gradient)
                
                Text(timeString)
                    .font(.system(size: 48, weight: .light, design: .rounded))
                
                Text(isRunning ? "Growing in faith" : "Tap to plant")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 250)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                leafRotation = 360
            }
        }
    }
}

// MARK: - Breathing Guide
struct BreathingGuide: View {
    @Binding var scale: CGFloat
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(appState.settings.theme.primaryColor.opacity(0.3))
                .frame(width: 8, height: 8)
                .scaleEffect(scale)
            
            Text("Breathe deeply")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Circle()
                .fill(appState.settings.theme.primaryColor.opacity(0.3))
                .frame(width: 8, height: 8)
                .scaleEffect(scale)
        }
    }
}

// MARK: - Prayer Text Card
struct PrayerTextCard: View {
    let prayer: Prayer
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 15) {
            Text(prayer.text)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            Divider()
                .padding(.horizontal, 40)
            
            VStack(spacing: 5) {
                Text("\"\(prayer.verse)\"")
                    .font(.callout)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                Text("— \(prayer.verseReference)")
                    .font(.caption)
                    .foregroundColor(appState.settings.theme.primaryColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Bottom Controls
struct BottomControls: View {
    let isTimerRunning: Bool
    let onShuffle: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: onShuffle) {
                VStack(spacing: 5) {
                    Image(systemName: "shuffle")
                        .font(.title2)
                    Text("Shuffle")
                        .font(.caption2)
                }
                .foregroundColor(appState.settings.theme.primaryColor)
            }
            .disabled(isTimerRunning)
            .opacity(isTimerRunning ? 0.5 : 1)
        }
    }
}

// MARK: - Completion View
struct CompletionView: View {
    let onDismiss: () -> Void
    @State private var animateCheck = false
    @State private var showStats = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated checkmark
            ZStack {
                Circle()
                    .fill(appState.settings.theme.primaryColor.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateCheck ? 1.2 : 0.8)
                
                Circle()
                    .fill(appState.settings.theme.gradient)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateCheck ? 1 : 0.5)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(animateCheck ? 1 : 0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCheck)
            
            Text("Prayer Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // XP earned
            if showStats {
                VStack(spacing: 15) {
                    HStack(spacing: 20) {
                        StatBubble(icon: "star.fill", value: "+\(LevelSystem.xpPerPrayer)", label: "XP", color: .yellow)
                        
                        if appState.streak.currentStreak > 1 {
                            StatBubble(icon: "flame.fill", value: "+\(appState.streak.currentStreak * LevelSystem.xpPerStreak)", label: "Streak", color: .orange)
                        }
                    }
                    
                    Text("Level \(appState.currentLevel) • \(appState.levelTitle)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity.combined(with: .scale))
            }
            
            Text("Your apps are now unlocked for 1 hour.\nMay peace be with you.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appState.settings.theme.gradient)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateCheck = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showStats = true
                }
            }
        }
    }
}

struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(value)
                    .fontWeight(.bold)
            }
            .font(.title3)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    PrayerSessionView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
