import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var appBlockingManager: AppBlockingManager

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \UserSettings.createdAt, order: .forward)
    private var settings: [UserSettings]

    @Query(sort: \BlockSelection.createdAt, order: .forward)
    private var selections: [BlockSelection]

    @Query(sort: \Streak.current, order: .reverse)
    private var streaks: [Streak]

    var body: some View {
        Group {
            if !subscriptionManager.isSubscribed {
                PaywallView()
            } else if (settings.first?.hasCompletedOnboarding ?? false) == false {
                OnboardingFlowView()
            } else {
                MainTabView()
            }
        }
        .task {
            bootstrapIfNeeded()
            await appBlockingManager.refreshAuthorizationStatus()
        }
    }

    private func bootstrapIfNeeded() {
        if settings.isEmpty {
            modelContext.insert(UserSettings())
        }
        if selections.isEmpty {
            modelContext.insert(BlockSelection())
        }
        if streaks.isEmpty {
            modelContext.insert(Streak())
        }

        // Keep the selected apps shielded after onboarding by default.
        // If the app was previously shielding, iOS keeps it until we clear it.
        // We only apply a shield here if onboarding is done and permissions exist; otherwise onboarding will guide it.
    }
}

