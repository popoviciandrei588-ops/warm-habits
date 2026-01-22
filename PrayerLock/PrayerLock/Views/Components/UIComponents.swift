import SwiftUI

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @EnvironmentObject var appState: AppState
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                appState.settings.theme.primaryColor.opacity(0.3),
                appState.settings.theme.secondaryColor.opacity(0.2),
                Color(.systemBackground)
            ],
            startPoint: animateGradient ? .topLeading : .topTrailing,
            endPoint: animateGradient ? .bottomTrailing : .bottomLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Level Badge
struct LevelBadge: View {
    let level: Int
    let size: CGFloat
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Circle()
                .fill(appState.settings.theme.gradient)
                .frame(width: size, height: size)
            
            Circle()
                .fill(Color(.systemBackground))
                .frame(width: size - 8, height: size - 8)
            
            VStack(spacing: 0) {
                Image(systemName: LevelSystem.iconForLevel(level))
                    .font(.system(size: size * 0.25))
                    .foregroundStyle(appState.settings.theme.gradient)
                
                Text("\(level)")
                    .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    .foregroundStyle(appState.settings.theme.gradient)
            }
        }
    }
}

// MARK: - XP Progress Bar
struct XPProgressBar: View {
    let progress: Double
    let currentXP: Int
    let neededXP: Int
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(appState.settings.theme.gradient)
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(response: 0.6), value: progress)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(currentXP) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(neededXP) XP to next level")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Streak Flame
struct StreakFlame: View {
    let streak: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Glow effect
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .blur(radius: 20)
                .opacity(0.5)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
            
            // Main flame
            Image(systemName: "flame.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .scaleEffect(isAnimating ? 1.05 : 1.0)
            
            // Streak number
            Text("\(streak)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .offset(y: 5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: DailyChallenge
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(challenge.isCompleted ? Color.green.opacity(0.2) : appState.settings.theme.primaryColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: challenge.icon)
                        .font(.title3)
                        .foregroundColor(appState.settings.theme.primaryColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(challenge.isCompleted)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(challenge.isCompleted ? Color.green : appState.settings.theme.primaryColor)
                            .frame(width: geometry.size.width * challenge.progressPercent, height: 6)
                    }
                }
                .frame(height: 6)
            }
            
            Spacer()
            
            VStack {
                Text("+\(challenge.xpReward)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(challenge.isCompleted ? .green : appState.settings.theme.primaryColor)
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? appState.settings.theme.gradient
                            : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                .lineLimit(2)
        }
        .frame(width: 80)
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    func createConfetti(in size: CGSize) {
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                color: colors.randomElement() ?? .blue,
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var scale: CGFloat
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: 8 * piece.scale, height: 12 * piece.scale)
            .rotationEffect(.degrees(rotation))
            .position(x: piece.x, y: piece.y + offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                    offsetY = 800
                    rotation = piece.rotation + Double.random(in: 360...720)
                }
                withAnimation(.easeIn(duration: 3).delay(1)) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Pulsing Button
struct PulsingButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    appState.settings.theme.gradient
                    
                    // Pulse effect
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .scaleEffect(isPulsing ? 2 : 0)
                        .opacity(isPulsing ? 0 : 0.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: appState.settings.theme.primaryColor.opacity(0.4), radius: 15, y: 8)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Mood Chip
struct MoodChip: View {
    let mood: PrayerMood
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? appState.settings.theme.gradient : LinearGradient(colors: [Color(.systemGray5), Color(.systemGray6)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: mood.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(mood.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? appState.settings.theme.primaryColor : .secondary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            )
    }
}

// MARK: - Level Up Modal
struct LevelUpModal: View {
    let level: Int
    let onDismiss: () -> Void
    @State private var animate = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Stars animation
                ZStack {
                    ForEach(0..<8) { i in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                            .offset(
                                x: animate ? cos(Double(i) * .pi / 4) * 80 : 0,
                                y: animate ? sin(Double(i) * .pi / 4) * 80 : 0
                            )
                            .opacity(animate ? 1 : 0)
                    }
                    
                    LevelBadge(level: level, size: 120)
                        .scaleEffect(animate ? 1 : 0.5)
                }
                
                Text("Level Up!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(appState.settings.theme.gradient)
                
                Text("You've reached Level \(level)")
                    .font(.title3)
                
                Text(LevelSystem.titleForLevel(level))
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(appState.settings.theme.primaryColor.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: onDismiss) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding()
                        .background(appState.settings.theme.gradient)
                        .cornerRadius(25)
                }
                .padding(.top)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(.systemBackground))
            )
            .padding(30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

// MARK: - Achievement Unlock Toast
struct AchievementToast: View {
    let achievement: Achievement
    @EnvironmentObject var appState: AppState
    @State private var showToast = false
    
    var body: some View {
        VStack {
            Spacer()
            
            if showToast {
                HStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(appState.settings.theme.gradient)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: achievement.icon)
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Achievement Unlocked!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(achievement.title)
                            .font(.headline)
                        
                        Text("+\(achievement.xpReward) XP")
                            .font(.caption)
                            .foregroundColor(appState.settings.theme.primaryColor)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showToast = false
                }
            }
        }
    }
}

// MARK: - Theme Preview Card
struct ThemePreviewCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme.gradient)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: theme.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 3)
                            .frame(width: 70, height: 70)
                    }
                }
                
                Text(theme.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
        }
        .buttonStyle(.plain)
    }
}
