import SwiftUI

struct DailyVerseView: View {
    @EnvironmentObject var appState: AppState
    @State private var showShareSheet = false
    @State private var animateIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color("PrayerBlue").opacity(0.1),
                        Color("PrayerPurple").opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Date header
                        VStack(spacing: 5) {
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Daily Verse")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        
                        // Verse card
                        VStack(spacing: 25) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color("PrayerBlue"))
                            
                            Text("\"\(appState.dailyVerse.text)\"")
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                            
                            Text("— \(appState.dailyVerse.reference)")
                                .font(.headline)
                                .foregroundColor(Color("PrayerBlue"))
                        }
                        .padding(30)
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 15, y: 10)
                        .padding(.horizontal)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 30)
                        
                        // Action buttons
                        HStack(spacing: 15) {
                            ActionButton(
                                icon: "arrow.clockwise",
                                label: "New Verse",
                                color: Color("PrayerPurple")
                            ) {
                                withAnimation {
                                    appState.dailyVerse = DailyVerseCollection.randomVerse()
                                }
                            }
                            
                            ActionButton(
                                icon: "square.and.arrow.up",
                                label: "Share",
                                color: Color("PrayerBlue")
                            ) {
                                shareVerse()
                            }
                        }
                        .padding(.horizontal)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        
                        // Reflection section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Reflect")
                                .font(.headline)
                            
                            Text("Take a moment to meditate on this verse. How does it speak to your heart today?")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                            
                            Button(action: {
                                appState.startPrayer()
                            }) {
                                HStack {
                                    Image(systemName: "hands.clap.fill")
                                    Text("Pray with this verse")
                                }
                                .fontWeight(.medium)
                                .foregroundColor(Color("PrayerBlue"))
                            }
                            .padding(.top, 5)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    func shareVerse() {
        let text = "\"\(appState.dailyVerse.text)\"\n\n— \(appState.dailyVerse.reference)\n\nShared from Prayer Lock"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DailyVerseView()
        .environmentObject(AppState())
}
