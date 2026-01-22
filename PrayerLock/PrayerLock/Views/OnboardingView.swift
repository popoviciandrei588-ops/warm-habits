import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color("PrayerBlue").opacity(0.3), Color("PrayerPurple").opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    ConceptPage()
                        .tag(1)
                    
                    PermissionPage()
                        .tag(2)
                    
                    AppSelectionPage()
                        .tag(3)
                    
                    ReadyPage()
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<5) { index in
                        Circle()
                            .fill(currentPage == index ? Color("PrayerBlue") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                // Navigation buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentPage < 4 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            Text("Next")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color("PrayerBlue"))
                                .cornerRadius(25)
                        }
                    } else {
                        Button(action: {
                            appState.completeOnboarding()
                        }) {
                            Text("Get Started")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color("PrayerBlue"))
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Onboarding Pages

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("PrayerBlue"), Color("PrayerPurple")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Prayer Lock")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Transform your screen time\ninto moments of prayer")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct ConceptPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Color("PrayerOrange"))
            
            Text("Pause Before You Scroll")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "lock.fill",
                    color: Color("PrayerBlue"),
                    text: "Block distracting apps"
                )
                
                FeatureRow(
                    icon: "hands.clap.fill",
                    color: Color("PrayerPurple"),
                    text: "Pray for 60 seconds"
                )
                
                FeatureRow(
                    icon: "lock.open.fill",
                    color: Color("PrayerGreen"),
                    text: "Apps unlock after prayer"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct PermissionPage: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "hourglass")
                .font(.system(size: 70))
                .foregroundColor(Color("PrayerBlue"))
            
            Text("Screen Time Permission")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("We need Screen Time access to help you pause before opening distracting apps.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }) {
                HStack {
                    Image(systemName: screenTimeManager.authorizationStatus == .authorized ? "checkmark.circle.fill" : "lock.shield")
                    Text(screenTimeManager.authorizationStatus == .authorized ? "Permission Granted" : "Grant Permission")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(screenTimeManager.authorizationStatus == .authorized ? Color("PrayerGreen") : Color("PrayerBlue"))
                .cornerRadius(25)
            }
            .disabled(screenTimeManager.authorizationStatus == .authorized)
            
            if let error = screenTimeManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct AppSelectionPage: View {
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    @State private var showingAppPicker = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "apps.iphone")
                .font(.system(size: 70))
                .foregroundColor(Color("PrayerPurple"))
            
            Text("Choose Apps to Block")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Select the apps you want to pray before using.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingAppPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(screenTimeManager.hasSelectedApps ? "\(screenTimeManager.selectedAppCount) Apps Selected" : "Select Apps")
                }
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color("PrayerPurple"))
                .cornerRadius(25)
            }
            .familyActivityPicker(isPresented: $showingAppPicker, selection: $screenTimeManager.selectedApps)
            .onChange(of: screenTimeManager.selectedApps) { _, newValue in
                screenTimeManager.saveSelection(newValue)
            }
            
            if screenTimeManager.hasSelectedApps {
                Text("You can change this later in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct ReadyPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("PrayerGreen"), Color("PrayerBlue")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("You're All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Start building a habit of\nprayer before distraction")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                StatPreview(icon: "flame.fill", color: .orange, label: "Track your prayer streak")
                StatPreview(icon: "book.fill", color: Color("PrayerBlue"), label: "Daily Bible verses")
                StatPreview(icon: "heart.fill", color: Color("PrayerPink"), label: "Choose your prayer mood")
            }
            .padding(.top)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

struct StatPreview: View {
    let icon: String
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
