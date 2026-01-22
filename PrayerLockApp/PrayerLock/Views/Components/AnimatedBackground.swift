import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "0F172A"),
                Color(hex: "1E3A5F"),
                Color(hex: "1E40AF").opacity(0.5)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct FloatingOrbs: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Orb 1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "3B82F6").opacity(0.4), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: animate ? 50 : -50, y: animate ? -30 : 30)
                .blur(radius: 40)
            
            // Orb 2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "8B5CF6").opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 250, height: 250)
                .offset(x: animate ? -70 : 70, y: animate ? 50 : -50)
                .blur(radius: 50)
            
            // Orb 3
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "EC4899").opacity(0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(x: animate ? 30 : -30, y: animate ? 80 : -80)
                .blur(radius: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        FloatingOrbs()
    }
}
