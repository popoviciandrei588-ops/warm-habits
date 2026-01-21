import SwiftUI

/// View shown when the prayer timer completes
struct PrayerCompletedView: View {
    let mood: Mood
    let duration: Int
    let prayer: ComposedPrayer?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.1),
                    Color(red: 0.08, green: 0.12, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Confetti effect (simplified)
            if showConfetti {
                ConfettiView()
            }
            
            VStack(spacing: 32) {
                Spacer()
                
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.green)
                }
                .scaleEffect(scale)
                
                // Completion message
                VStack(spacing: 12) {
                    Text("Prayer Complete! 🙏")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You've spent \(formattedDuration) with God")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Your apps are now unlocked")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(opacity)
                
                // Stats card
                statsCard
                    .opacity(opacity)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Continue Your Day")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    
                    Button(action: {
                        // Option to pray again
                        dismiss()
                    }) {
                        Text("Pray Again")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .opacity(opacity)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                opacity = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showConfetti = true
            }
        }
    }
    
    // MARK: - Stats Card
    private var statsCard: some View {
        HStack(spacing: 32) {
            StatColumn(
                icon: "clock.fill",
                value: formattedDuration,
                label: "Time Prayed"
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatColumn(
                icon: "heart.fill",
                value: mood.emoji,
                label: mood.displayName
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatColumn(
                icon: "flame.fill",
                value: "1", // Would come from streak data
                label: "Day Streak"
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var formattedDuration: String {
        if duration >= 60 {
            let minutes = duration / 60
            let seconds = duration % 60
            if seconds == 0 {
                return "\(minutes) min"
            }
            return "\(minutes)m \(seconds)s"
        }
        return "\(duration)s"
    }
}

// MARK: - Supporting Views

struct StatColumn: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.indigo)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

/// Simple confetti animation view
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        let colors: [Color] = [.indigo, .purple, .green, .yellow, .pink, .orange]
        
        particles = (0..<30).map { _ in
            ConfettiParticle(
                color: colors.randomElement() ?? .indigo,
                size: CGFloat.random(in: 4...12),
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let delay = Double.random(in: 0...1.5)
            
            withAnimation(
                Animation.easeOut(duration: 2.5)
                    .delay(delay)
            ) {
                particles[i].position.y = UIScreen.main.bounds.height + 50
                particles[i].position.x += CGFloat.random(in: -100...100)
            }
            
            withAnimation(
                Animation.easeIn(duration: 1.0)
                    .delay(delay + 1.5)
            ) {
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var opacity: Double
}

// MARK: - Preview
#Preview {
    PrayerCompletedView(
        mood: .grateful,
        duration: 60,
        prayer: nil
    )
}
