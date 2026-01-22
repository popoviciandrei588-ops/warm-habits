import SwiftUI

struct PrayerSessionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var screenTimeManager: ScreenTimeManager
    
    @State private var timeRemaining: Int = 60
    @State private var isTimerRunning = false
    @State private var hasCompleted = false
    @State private var showingCompletion = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var progress: Double {
        1.0 - Double(timeRemaining) / Double(appState.settings.prayerDurationSeconds)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color("PrayerBlue").opacity(0.3),
                    Color("PrayerPurple").opacity(0.2),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showingCompletion {
                CompletionView(onDismiss: {
                    appState.completePrayer()
                    screenTimeManager.temporarilyDisableBlocking(for: 3600) // 1 hour
                })
            } else {
                VStack(spacing: 30) {
                    // Close button
                    HStack {
                        Spacer()
                        Button(action: {
                            appState.showPrayerScreen = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Mood indicator
                    if let prayer = appState.currentPrayer {
                        HStack {
                            Image(systemName: prayer.mood.icon)
                            Text(prayer.mood.rawValue)
                        }
                        .font(.subheadline)
                        .foregroundColor(Color("PrayerBlue"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("PrayerBlue").opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // Timer circle
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 200, height: 200)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("PrayerBlue"), Color("PrayerPurple")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        
                        // Timer text
                        VStack(spacing: 5) {
                            Text(timeString)
                                .font(.system(size: 48, weight: .light, design: .rounded))
                            
                            Text(isTimerRunning ? "Praying..." : "Tap to begin")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        if !isTimerRunning {
                            startTimer()
                        }
                    }
                    
                    // Prayer text
                    if let prayer = appState.currentPrayer {
                        VStack(spacing: 20) {
                            Text(prayer.text)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal)
                            
                            VStack(spacing: 5) {
                                Text("\"\(prayer.verse)\"")
                                    .font(.callout)
                                    .italic()
                                    .multilineTextAlignment(.center)
                                
                                Text("— \(prayer.verseReference)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Shuffle button
                    Button(action: {
                        appState.getNewPrayer()
                    }) {
                        Label("Different Prayer", systemImage: "shuffle")
                            .font(.subheadline)
                            .foregroundColor(Color("PrayerBlue"))
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            timeRemaining = appState.settings.prayerDurationSeconds
        }
        .onReceive(timer) { _ in
            if isTimerRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if timeRemaining == 0 && isTimerRunning {
                completeTimer()
            }
        }
    }
    
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        }
        return "\(seconds)"
    }
    
    func startTimer() {
        isTimerRunning = true
    }
    
    func completeTimer() {
        isTimerRunning = false
        hasCompleted = true
        withAnimation {
            showingCompletion = true
        }
    }
}

struct CompletionView: View {
    let onDismiss: () -> Void
    @State private var animateCheck = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("PrayerGreen").opacity(0.2))
                    .frame(width: 150, height: 150)
                    .scaleEffect(animateCheck ? 1.1 : 0.8)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("PrayerGreen"))
                    .scaleEffect(animateCheck ? 1 : 0.5)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCheck)
            
            Text("Prayer Complete")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your apps are now unlocked.\nMay peace be with you.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrayerGreen"))
                    .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateCheck = true
            }
        }
    }
}

#Preview {
    PrayerSessionView()
        .environmentObject(AppState())
        .environmentObject(ScreenTimeManager())
}
