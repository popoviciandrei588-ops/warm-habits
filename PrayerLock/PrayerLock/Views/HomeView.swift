import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Greeting
                    GreetingCard()
                    
                    // Streak Card
                    StreakCard()
                    
                    // Mood Selector
                    MoodSelectorCard()
                    
                    // Prayer Button
                    PrayNowButton()
                    
                    // Quick Stats
                    QuickStatsCard()
                    
                    // Blocking Status
                    BlockingStatusCard()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prayer Lock")
        }
    }
}

// MARK: - Components

struct GreetingCard: View {
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(greeting)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Take a moment to pray today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "sun.max.fill")
                .font(.title)
                .foregroundColor(.orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct StreakCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(appState.streak.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("Day Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(appState.streak.totalPrayers)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Total Prayers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
                .frame(height: 40)
            
            VStack {
                Text("\(appState.streak.longestStreak)")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Best Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MoodSelectorCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("How are you feeling?")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PrayerMood.allCases, id: \.self) { mood in
                        MoodButton(
                            mood: mood,
                            isSelected: appState.settings.selectedMood == mood
                        ) {
                            appState.selectMood(mood)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct MoodButton: View {
    let mood: PrayerMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mood.icon)
                    .font(.title2)
                
                Text(mood.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("PrayerBlue") : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

struct PrayNowButton: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: {
            appState.startPrayer()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "hands.clap.fill")
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text("Start Prayer")
                        .font(.headline)
                    Text("\(appState.settings.prayerDurationSeconds) seconds of peace")
                        .font(.caption)
                        .opacity(0.9)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color("PrayerBlue"), Color("PrayerPurple")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .shadow(color: Color("PrayerBlue").opacity(0.3), radius: 10, y: 5)
    }
}

struct QuickStatsCard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today's Focus")
                    .font(.headline)
                Spacer()
                
                if appState.streak.hasPrayedToday() {
                    Label("Prayed Today", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            HStack(spacing: 15) {
                StatBox(
                    icon: "clock.fill",
                    value: "\(appState.settings.prayerDurationSeconds)s",
                    label: "Duration"
                )
                
                StatBox(
                    icon: "heart.fill",
                    value: appState.settings.selectedMood.rawValue,
                    label: "Mood"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("PrayerBlue"))
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct BlockingStatusCard: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        HStack {
            Image(systemName: screenTimeManager.isBlocking ? "lock.fill" : "lock.open.fill")
                .font(.title2)
                .foregroundColor(screenTimeManager.isBlocking ? Color("PrayerBlue") : .gray)
            
            VStack(alignment: .leading) {
                Text(screenTimeManager.isBlocking ? "App Blocking Active" : "App Blocking Disabled")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(screenTimeManager.selectedAppCount) apps selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { screenTimeManager.isBlocking },
                set: { newValue in
                    if newValue {
                        screenTimeManager.enableBlocking()
                    } else {
                        screenTimeManager.disableBlocking()
                    }
                }
            ))
            .labelsHidden()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
