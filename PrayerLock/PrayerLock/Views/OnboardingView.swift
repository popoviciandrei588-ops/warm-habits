import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var currentPage = 0
    @State private var showContinue = false
    
    let totalPages = 5
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedOnboardingBackground(currentPage: currentPage)
            
            VStack(spacing: 0) {
                // Progress bar
                OnboardingProgressBar(current: currentPage, total: totalPages)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                
                // Page content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    FeaturesPage()
                        .tag(1)
                    
                    PermissionPage()
                        .tag(2)
                    
                    AppSelectionPage()
                        .tag(3)
                    
                    ReadyPage()
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5), value: currentPage)
                
                // Navigation
                NavigationButtons(
                    currentPage: $currentPage,
                    totalPages: totalPages,
                    onComplete: {
                        appState.completeOnboarding()
                    }
                )
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedOnboardingBackground: View {
    let currentPage: Int
    @State private var animate = false
    
    var colors: [Color] {
        switch currentPage {
        case 0: return [Color(red: 0.2, green: 0.5, blue: 0.8), Color(red: 0.4, green: 0.7, blue: 0.9)]
        case 1: return [Color(red: 0.6, green: 0.4, blue: 0.8), Color(red: 0.8, green: 0.6, blue: 0.9)]
        case 2: return [Color(red: 0.95, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.7, blue: 0.4)]
        case 3: return [Color(red: 0.2, green: 0.6, blue: 0.4), Color(red: 0.4, green: 0.8, blue: 0.5)]
        default: return [Color(red: 0.9, green: 0.4, blue: 0.5), Color(red: 1.0, green: 0.6, blue: 0.7)]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [colors[0].opacity(0.3), colors[1].opacity(0.2), Color(.systemBackground)],
                startPoint: animate ? .topLeading : .topTrailing,
                endPoint: animate ? .bottomTrailing : .bottomLeading
            )
            
            // Floating shapes
            ForEach(0..<5) { i in
                Circle()
                    .fill(colors[0].opacity(0.1))
                    .frame(width: CGFloat.random(in: 100...200))
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : CGFloat.random(in: -100...100),
                        y: animate ? CGFloat.random(in: -300...300) : CGFloat.random(in: -200...200)
                    )
                    .blur(radius: 50)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animate)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.white : Color.white.opacity(0.3))
                    .frame(height: 4)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    @Binding var currentPage: Int
    let totalPages: Int
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            // Back button
            if currentPage > 0 {
                Button(action: {
                    withAnimation {
                        currentPage -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Next/Start button
            Button(action: {
                if currentPage < totalPages - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
            }) {
                HStack {
                    Text(currentPage == totalPages - 1 ? "Start Praying" : "Continue")
                    Image(systemName: currentPage == totalPages - 1 ? "arrow.right.circle.fill" : "chevron.right")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.5, blue: 0.8), Color(red: 0.4, green: 0.7, blue: 0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
            }
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated logo
            ZStack {
                // Outer glow rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.blue.opacity(0.2 - Double(i) * 0.05), lineWidth: 2)
                        .frame(width: 180 + CGFloat(i * 40), height: 180 + CGFloat(i * 40))
                        .scaleEffect(animate ? 1.1 : 0.9)
                }
                
                // Main icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.5, blue: 0.8), Color(red: 0.6, green: 0.4, blue: 0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .blue.opacity(0.4), radius: 20, y: 10)
                    
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 55))
                        .foregroundColor(.white)
                }
            }
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
            
            VStack(spacing: 15) {
                Text("Prayer Lock")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                
                Text("Transform your screen time\ninto moments of peace")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Feature pills
            HStack(spacing: 10) {
                FeaturePill(icon: "lock.fill", text: "Focus")
                FeaturePill(icon: "flame.fill", text: "Streaks")
                FeaturePill(icon: "star.fill", text: "Grow")
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        .onAppear { animate = true }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Features Page
struct FeaturesPage: View {
    @State private var animatedFeatures: Set<Int> = []
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("How It Works")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                FeatureCard(
                    number: 1,
                    icon: "apps.iphone",
                    title: "Select Apps",
                    description: "Choose which apps you want to pause before using",
                    color: .purple,
                    isAnimated: animatedFeatures.contains(0)
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring()) { animatedFeatures.insert(0) }
                    }
                }
                
                FeatureCard(
                    number: 2,
                    icon: "hands.clap.fill",
                    title: "Pray First",
                    description: "Complete a peaceful 60-second prayer session",
                    color: .blue,
                    isAnimated: animatedFeatures.contains(1)
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring()) { animatedFeatures.insert(1) }
                    }
                }
                
                FeatureCard(
                    number: 3,
                    icon: "lock.open.fill",
                    title: "Unlock & Enjoy",
                    description: "Apps unlock after prayer - mindfully use your time",
                    color: .green,
                    isAnimated: animatedFeatures.contains(2)
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.spring()) { animatedFeatures.insert(2) }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct FeatureCard: View {
    let number: Int
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isAnimated: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("\(number)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color.opacity(0.3))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .offset(x: isAnimated ? 0 : 100)
        .opacity(isAnimated ? 1 : 0)
    }
}

// MARK: - Permission Page
struct PermissionPage: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon with status
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 60))
                    .foregroundColor(statusColor)
            }
            
            VStack(spacing: 15) {
                Text("Screen Time Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("We need Screen Time permission to help you pause before opening distracting apps. Your data stays private on your device.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Permission button
            if screenTimeManager.authorizationStatus != .authorized {
                Button(action: {
                    isRequesting = true
                    Task {
                        await screenTimeManager.requestAuthorization()
                        isRequesting = false
                    }
                }) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "lock.shield.fill")
                        }
                        Text(isRequesting ? "Requesting..." : "Grant Permission")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.orange, .red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                }
                .disabled(isRequesting)
                .padding(.horizontal, 40)
            } else {
                // Success state
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Permission Granted")
                }
                .font(.headline)
                .foregroundColor(.green)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(15)
            }
            
            // Privacy note
            HStack(spacing: 8) {
                Image(systemName: "hand.raised.fill")
                    .font(.caption)
                Text("Your data never leaves your device")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
    
    var statusIcon: String {
        switch screenTimeManager.authorizationStatus {
        case .authorized: return "checkmark.shield.fill"
        case .denied: return "xmark.shield.fill"
        case .notDetermined: return "hourglass"
        }
    }
    
    var statusColor: Color {
        switch screenTimeManager.authorizationStatus {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        }
    }
}

// MARK: - App Selection Page
struct AppSelectionPage: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingPicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: "apps.iphone")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 15) {
                Text("Choose Your Apps")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Select the apps you want to pray before using. Common choices include social media, games, and streaming apps.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // App selection button
            Button(action: { showingPicker = true }) {
                VStack(spacing: 12) {
                    if screenTimeManager.hasSelectedApps {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(screenTimeManager.selectedAppCount) Apps Selected")
                                .fontWeight(.semibold)
                        }
                    } else {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Select Apps to Block")
                                .fontWeight(.semibold)
                        }
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
            }
            .padding(.horizontal, 40)
            .familyActivityPicker(isPresented: $showingPicker, selection: $screenTimeManager.selectedApps)
            .onChange(of: screenTimeManager.selectedApps) { _, newValue in
                screenTimeManager.saveSelection(newValue)
            }
            
            // Suggestions
            VStack(spacing: 10) {
                Text("Popular choices:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    AppSuggestionChip(name: "Instagram")
                    AppSuggestionChip(name: "TikTok")
                    AppSuggestionChip(name: "Twitter")
                    AppSuggestionChip(name: "YouTube")
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct AppSuggestionChip: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .cornerRadius(15)
    }
}

// MARK: - Ready Page
struct ReadyPage: View {
    @State private var animate = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Celebration animation
            ZStack {
                // Particles
                ForEach(0..<12) { i in
                    Circle()
                        .fill(Color.pink.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(
                            x: animate ? cos(Double(i) * .pi / 6) * 100 : 0,
                            y: animate ? sin(Double(i) * .pi / 6) * 100 : 0
                        )
                        .opacity(animate ? 0 : 1)
                }
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: .purple.opacity(0.4), radius: 20, y: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(animate ? 1 : 0.5)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animate)
            
            VStack(spacing: 15) {
                Text("You're Ready!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Begin your journey to more mindful screen time through prayer")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Preview features
            VStack(spacing: 15) {
                ReadyFeatureRow(icon: "flame.fill", color: .orange, text: "Track your prayer streak")
                ReadyFeatureRow(icon: "star.fill", color: .yellow, text: "Earn XP and level up")
                ReadyFeatureRow(icon: "trophy.fill", color: .purple, text: "Unlock achievements")
                ReadyFeatureRow(icon: "book.fill", color: .blue, text: "Daily Bible verses")
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animate = true
            }
        }
    }
}

struct ReadyFeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
