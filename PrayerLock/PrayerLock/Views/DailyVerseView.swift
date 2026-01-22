import SwiftUI

struct DailyVerseView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateIn = false
    @State private var showBookmark = false
    @State private var cardOffset: CGFloat = 50
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                AnimatedGradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                        // Date and streak header
                        HeaderSection()
                        
                        // Main verse card
                        VerseCard()
                        
                        // Action buttons
                        ActionButtonsRow()
                        
                        // Reflection section
                        ReflectionSection()
                        
                        // More verses
                        MoreVersesSection()
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 8) {
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Daily Verse")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Streak indicator
            if appState.streak.currentStreak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(appState.streak.currentStreak) day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
            }
        }
        .padding(.top, 20)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Verse Card
struct VerseCard: View {
    @EnvironmentObject var appState: AppState
    @State private var isFlipped = false
    @State private var showGlow = false
    
    var body: some View {
        ZStack {
            // Glow effect
            RoundedRectangle(cornerRadius: 25)
                .fill(appState.settings.theme.gradient)
                .blur(radius: 30)
                .opacity(showGlow ? 0.3 : 0.1)
                .scaleEffect(showGlow ? 1.05 : 1.0)
            
            // Card content
            VStack(spacing: 25) {
                // Book icon with animation
                ZStack {
                    Circle()
                        .fill(appState.settings.theme.primaryColor.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "book.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(appState.settings.theme.gradient)
                }
                
                // Verse text
                Text("\"\(appState.dailyVerse.text)\"")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Divider with cross
                HStack {
                    Rectangle()
                        .fill(appState.settings.theme.primaryColor.opacity(0.3))
                        .frame(height: 1)
                    
                    Image(systemName: "cross.fill")
                        .font(.caption)
                        .foregroundStyle(appState.settings.theme.gradient)
                    
                    Rectangle()
                        .fill(appState.settings.theme.primaryColor.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal, 40)
                
                // Reference
                Text(appState.dailyVerse.reference)
                    .font(.headline)
                    .foregroundStyle(appState.settings.theme.gradient)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

// MARK: - Action Buttons Row
struct ActionButtonsRow: View {
    @EnvironmentObject var appState: AppState
    @State private var isSaved = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Refresh button
            ActionCircleButton(
                icon: "arrow.clockwise",
                label: "New Verse"
            ) {
                withAnimation(.spring()) {
                    appState.dailyVerse = DailyVerseCollection.randomVerse()
                }
            }
            
            // Share button
            ActionCircleButton(
                icon: "square.and.arrow.up",
                label: "Share"
            ) {
                shareVerse()
            }
            
            // Save button
            ActionCircleButton(
                icon: isSaved ? "bookmark.fill" : "bookmark",
                label: isSaved ? "Saved" : "Save"
            ) {
                withAnimation(.spring()) {
                    isSaved.toggle()
                }
            }
            
            // Copy button
            ActionCircleButton(
                icon: "doc.on.doc",
                label: "Copy"
            ) {
                copyVerse()
            }
        }
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
    
    func copyVerse() {
        let text = "\"\(appState.dailyVerse.text)\"\n— \(appState.dailyVerse.reference)"
        UIPasteboard.general.string = text
    }
}

struct ActionCircleButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(appState.settings.theme.primaryColor.opacity(0.1))
                        .frame(width: 55, height: 55)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(appState.settings.theme.gradient)
                }
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reflection Section
struct ReflectionSection: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(appState.settings.theme.gradient)
                    Text("Reflect")
                        .font(.headline)
                }
                
                Text("Take a moment to meditate on this verse. How does it speak to your heart today? What is God trying to tell you through these words?")
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(appState.settings.theme.gradient)
                    .cornerRadius(15)
                }
            }
        }
    }
}

// MARK: - More Verses Section
struct MoreVersesSection: View {
    @EnvironmentObject var appState: AppState
    let suggestedVerses = DailyVerseCollection.verses.shuffled().prefix(3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("More Inspiration")
                .font(.headline)
            
            ForEach(Array(suggestedVerses)) { verse in
                Button(action: {
                    withAnimation(.spring()) {
                        appState.dailyVerse = verse
                    }
                }) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(appState.settings.theme.gradient)
                            .font(.caption)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(verse.text)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            
                            Text(verse.reference)
                                .font(.caption)
                                .foregroundStyle(appState.settings.theme.gradient)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    DailyVerseView()
        .environmentObject(AppState())
}
