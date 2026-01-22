import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
        .environmentObject(SubscriptionManager())
        .environmentObject(BlockingManager())
}
