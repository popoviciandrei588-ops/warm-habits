import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        Group {
            if !appState.settings.hasCompletedOnboarding {
                OnboardingView()
            } else if appState.showPrayerScreen {
                PrayerSessionView()
            } else {
                MainTabView()
            }
        }
        .animation(.easeInOut, value: appState.settings.hasCompletedOnboarding)
        .animation(.easeInOut, value: appState.showPrayerScreen)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            DailyVerseView()
                .tabItem {
                    Label("Verse", systemImage: "book.fill")
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color("PrayerBlue"))
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
