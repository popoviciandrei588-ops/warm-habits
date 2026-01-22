import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var blockingManager: BlockingManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var statsManager = StatsManager()
    @State private var showPrayerFlow = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: PLSpacing.lg) {
                    // Header with streak
                    headerSection
                    
                    // Quick stats
                    quickStatsSection
                    
                    // Main action card
                    mainActionCard
                    
                    // Today's verse preview
                    versePreviewCard
                    
                    // Blocking status
                    blockingStatusCard
                }
                .padding(.horizontal, PLSpacing.md)
                .padding(.bottom, PLSpacing.xxl)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prayer Lock")
            .onAppear {
                statsManager.setup(modelContext: modelContext)
            }
            .fullScreenCover(isPresented: $showPrayerFlow) {
                PrayerFlowView()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: PLSpacing.xxs) {
                Text(greeting)
                    .font(PLTypography.headlineMedium)
                    .foregroundColor(.primary)
                
                Text("Keep your streak going!")
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StreakBadge(streak: statsManager.currentStreak, size: .medium)
        }
        .padding(.top, PLSpacing.md)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    // MARK: - Quick Stats
    private var quickStatsSection: some View {
        HStack(spacing: PLSpacing.sm) {
            StatCard(
                icon: "clock.fill",
                title: "Minutes",
                value: "\(statsManager.totalMinutes)",
                color: Color(hex: "3B82F6")
            )
            
            StatCard(
                icon: "hands.sparkles.fill",
                title: "Sessions",
                value: "\(statsManager.totalSessions)",
                color: Color(hex: "8B5CF6")
            )
        }
    }
    
    // MARK: - Main Action Card
    private var mainActionCard: some View {
        VStack(spacing: PLSpacing.lg) {
            if appState.isUnlocked, let expiresAt = appState.unlockExpiresAt {
                // Unlocked state
                VStack(spacing: PLSpacing.md) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Apps Unlocked")
                        .font(PLTypography.headlineMedium)
                    
                    Text("Until \(expiresAt.formatted(date: .omitted, time: .shortened))")
                        .font(PLTypography.bodyMedium)
                        .foregroundColor(.secondary)
                    
                    Button {
                        appState.lockApps()
                        blockingManager.startBlocking()
                    } label: {
                        Text("Lock Now")
                    }
                    .buttonStyle(.plSecondary)
                    .padding(.horizontal, PLSpacing.xxl)
                }
            } else {
                // Locked state
                VStack(spacing: PLSpacing.md) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "8B5CF6")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("Ready to Pray?")
                        .font(PLTypography.headlineMedium)
                    
                    Text("Complete a prayer to unlock your apps")
                        .font(PLTypography.bodyMedium)
                        .foregroundColor(.secondary)
                    
                    Button {
                        if subscriptionManager.hasActiveSubscription {
                            showPrayerFlow = true
                        } else {
                            appState.showPaywall = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hands.sparkles.fill")
                            Text("Start Prayer")
                        }
                    }
                    .buttonStyle(.plPrimary)
                    .padding(.horizontal, PLSpacing.xl)
                }
            }
        }
        .padding(PLSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.xl))
        .plShadowMedium()
    }
    
    // MARK: - Verse Preview
    private var versePreviewCard: some View {
        let verse = Verse.verseOfTheDay()
        
        return VStack(alignment: .leading, spacing: PLSpacing.sm) {
            HStack {
                Text("Verse of the Day")
                    .font(PLTypography.titleSmall)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Text("\"\(verse.text)\"")
                .font(PLTypography.bodyMedium)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            Text(verse.reference)
                .font(PLTypography.labelMedium)
                .foregroundColor(Color(hex: "3B82F6"))
        }
        .padding(PLSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
        .plShadowSmall()
    }
    
    // MARK: - Blocking Status
    private var blockingStatusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: PLSpacing.xxs) {
                Text("Blocking Status")
                    .font(PLTypography.titleSmall)
                    .foregroundColor(.primary)
                
                Text("\(blockingManager.selectedAppsCount) apps protected")
                    .font(PLTypography.bodySmall)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(blockingManager.isBlocking ? Color(hex: "10B981") : Color(hex: "EF4444"))
                .frame(width: 12, height: 12)
            
            Text(blockingManager.isBlocking ? "Active" : "Inactive")
                .font(PLTypography.labelMedium)
                .foregroundColor(blockingManager.isBlocking ? Color(hex: "10B981") : Color(hex: "EF4444"))
        }
        .padding(PLSpacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
        .plShadowSmall()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(BlockingManager())
        .environmentObject(SubscriptionManager())
        .modelContainer(for: [PrayerSession.self, DailyStreak.self])
}
