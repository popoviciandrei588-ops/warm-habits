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
        .animation(.easeInOut(duration: 0.4), value: appState.settings.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: appState.showPrayerScreen)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                }
                .tag(0)
            
            DailyVerseView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "book.fill" : "book")
                        Text("Verse")
                    }
                }
                .tag(1)
            
            StatsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                        Text("Journey")
                    }
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "gearshape.fill" : "gearshape")
                        Text("Settings")
                    }
                }
                .tag(3)
        }
        .tint(appState.settings.theme.primaryColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
