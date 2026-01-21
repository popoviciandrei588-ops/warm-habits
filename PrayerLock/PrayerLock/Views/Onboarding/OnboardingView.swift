import SwiftUI

/// Main onboarding view that guides users through the app setup
struct OnboardingView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Binding var hasCompletedOnboarding: Bool
    
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "🙏",
            title: "Welcome to Prayer Lock",
            subtitle: "Transform your screen time into sacred moments",
            description: "Phone pings make prayer an afterthought. Prayer Lock flips that—creating a prayer pause before your most distracting apps open."
        ),
        OnboardingPage(
            icon: "🔒",
            title: "How It Works",
            subtitle: "Simple. Powerful. Transformative.",
            description: "1. Select apps you want to pause before opening\n2. When you try to open them, you'll pray first\n3. After 60 seconds of prayer, the app unlocks\n4. Build a habit of putting God first"
        ),
        OnboardingPage(
            icon: "📱",
            title: "Screen Time Permission",
            subtitle: "We need your permission to help you",
            description: "To pause distracting apps, Prayer Lock needs Screen Time access. This allows us to show a prayer screen before selected apps open."
        ),
        OnboardingPage(
            icon: "✨",
            title: "Ready to Begin",
            subtitle: "Your prayer journey starts now",
            description: "Select the apps you want to transform into prayer opportunities. You can change these anytime in settings."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.15, green: 0.15, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isPermissionPage: index == 2,
                            screenTimeManager: screenTimeManager
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicator and buttons
                VStack(spacing: 24) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Text("Back")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            if currentPage < pages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                // Complete onboarding
                                hasCompletedOnboarding = true
                            }
                        }) {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.indigo, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(currentPage == 2 && !screenTimeManager.authorizationStatus.isAuthorized)
                        .opacity(currentPage == 2 && !screenTimeManager.authorizationStatus.isAuthorized ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 48)
            }
        }
    }
}

/// Individual onboarding page data
struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

/// View for a single onboarding page
struct OnboardingPageView: View {
    let page: OnboardingPage
    let isPermissionPage: Bool
    @ObservedObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            Text(page.icon)
                .font(.system(size: 80))
                .padding(.bottom, 16)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text(page.subtitle)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
            
            // Permission button (only on permission page)
            if isPermissionPage {
                VStack(spacing: 16) {
                    if screenTimeManager.authorizationStatus.isAuthorized {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Permission Granted")
                                .foregroundColor(.green)
                        }
                        .font(.headline)
                        .padding(.top, 24)
                    } else {
                        Button(action: {
                            Task {
                                await screenTimeManager.requestAuthorization()
                            }
                        }) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Grant Screen Time Access")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.top, 24)
                        
                        if screenTimeManager.authorizationStatus == .denied {
                            Text("Permission denied. Please enable in Settings > Screen Time > Prayer Lock")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
