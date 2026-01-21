import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PrayerHomeView()
                .tabItem { Label("Pray", systemImage: "lock.shield") }

            StatsView()
                .tabItem { Label("Journey", systemImage: "chart.line.uptrend.xyaxis") }

            VerseView()
                .tabItem { Label("Verse", systemImage: "book") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

// MARK: - Placeholders (filled in next steps)

struct PrayerHomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("Before you scroll, pause and pray.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("Start a short prayer lock to unlock your chosen apps.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                NavigationLink("Begin") {
                    MoodSelectionView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Prayer Lock")
        }
    }
}

struct StatsView: View {
    var body: some View {
        NavigationStack {
            Text("Prayer journey analytics (coming next).")
                .foregroundStyle(.secondary)
                .padding()
                .navigationTitle("Journey")
        }
    }
}

struct VerseView: View {
    var body: some View {
        NavigationStack {
            Text("Verse of the day (coming next).")
                .foregroundStyle(.secondary)
                .padding()
                .navigationTitle("Verse")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("Lock time + permissions + account (coming next).")
                .foregroundStyle(.secondary)
                .padding()
                .navigationTitle("Settings")
        }
    }
}

