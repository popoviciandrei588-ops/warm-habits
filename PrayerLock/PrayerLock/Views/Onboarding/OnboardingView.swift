import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var blockingManager: BlockingManager
    @State private var currentPage = 0
    @State private var showPermissionRequest = false
    @State private var showAppPicker = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            FloatingOrbs()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < 2 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = 2
                            }
                        }
                        .font(PLTypography.labelLarge)
                        .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, PLSpacing.lg)
                .padding(.top, PLSpacing.md)
                
                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicators
                HStack(spacing: PLSpacing.xs) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1)
                            .animation(.plSpring, value: currentPage)
                    }
                }
                .padding(.bottom, PLSpacing.lg)
                
                // Action button
                Button {
                    handleAction()
                } label: {
                    Text(buttonTitle)
                        .font(PLTypography.titleMedium)
                        .foregroundColor(Color(hex: "1E3A5F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PLSpacing.md)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
                }
                .padding(.horizontal, PLSpacing.lg)
                .padding(.bottom, PLSpacing.xxl)
            }
        }
        .familyActivityPicker(
            isPresented: $showAppPicker,
            selection: $blockingManager.selectedApps
        )
        .onChange(of: blockingManager.selectedApps) { _, _ in
            if blockingManager.hasSelectedApps {
                completeOnboarding()
            }
        }
    }
    
    private var buttonTitle: String {
        switch currentPage {
        case 0: return "Continue"
        case 1: return "Continue"
        case 2: return blockingManager.isAuthorized ? "Select Apps to Block" : "Enable Screen Time"
        default: return "Continue"
        }
    }
    
    private func handleAction() {
        switch currentPage {
        case 0, 1:
            withAnimation {
                currentPage += 1
            }
        case 2:
            if blockingManager.isAuthorized {
                showAppPicker = true
            } else {
                Task {
                    try? await blockingManager.requestAuthorization()
                    if blockingManager.isAuthorized {
                        showAppPicker = true
                    }
                }
            }
        default:
            break
        }
    }
    
    private func completeOnboarding() {
        blockingManager.startBlocking()
        withAnimation {
            appState.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Page 1
struct OnboardingPage1: View {
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            VStack(spacing: PLSpacing.md) {
                Text("Your phone is taking\nyou away from God")
                    .font(PLTypography.displaySmall)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Prayer Lock helps you pause before\nopening distracting apps")
                    .font(PLTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, PLSpacing.lg)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}

// MARK: - Page 2
struct OnboardingPage2: View {
    @State private var appear = false
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            VStack(spacing: PLSpacing.md) {
                Text("Unlock prayer,\nunlock peace")
                    .font(PLTypography.displaySmall)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Complete a 60-second prayer before\naccessing blocked apps")
                    .font(PLTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, PLSpacing.lg)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}

// MARK: - Page 3
struct OnboardingPage3: View {
    @State private var appear = false
    @EnvironmentObject var blockingManager: BlockingManager
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            Image(systemName: "apps.iphone")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
            
            VStack(spacing: PLSpacing.md) {
                Text("Choose your\ndistractions")
                    .font(PLTypography.displaySmall)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Select the apps that pull you away\nfrom what matters most")
                    .font(PLTypography.bodyLarge)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                if blockingManager.isAuthorized {
                    HStack(spacing: PLSpacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "10B981"))
                        Text("Screen Time access granted")
                            .font(PLTypography.labelLarge)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, PLSpacing.md)
                    .opacity(appear ? 1 : 0)
                }
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, PLSpacing.lg)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(BlockingManager())
}
