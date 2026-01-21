import SwiftUI
import SwiftData

/// View showing the verse of the day with a beautiful, contemplative design
struct VerseView: View {
    @Query(sort: \VerseOfDay.date, order: .reverse) private var savedVerses: [VerseOfDay]
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentVerse: (text: String, reference: String)?
    @State private var isFavorite = false
    @State private var showShareSheet = false
    @State private var animateIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                backgroundGradient
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Main verse card
                    verseCard
                    
                    Spacer()
                    
                    // Action buttons
                    actionButtons
                    
                    // Quick navigation to favorites
                    if !savedVerses.isEmpty {
                        favoritesHint
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshVerse) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                loadVerseOfDay()
                withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                    animateIn = true
                }
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.15, green: 0.12, blue: 0.25),
                Color(red: 0.1, green: 0.1, blue: 0.18),
                Color(red: 0.08, green: 0.08, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Verse Card
    private var verseCard: some View {
        VStack(spacing: 32) {
            // Decorative quote mark
            Text(""")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.indigo.opacity(0.3))
                .offset(y: 20)
            
            if let verse = currentVerse {
                // Verse text
                Text(verse.text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal)
                
                // Reference
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.indigo)
                        .frame(width: 30, height: 2)
                    
                    Text(verse.reference)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                    
                    Rectangle()
                        .fill(Color.indigo)
                        .frame(width: 30, height: 2)
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
            
            // Closing quote
            Text(""")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.indigo.opacity(0.3))
                .offset(y: -20)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.indigo.opacity(0.5), Color.purple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 30)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 20) {
            // Favorite button
            ActionButton(
                icon: isFavorite ? "heart.fill" : "heart",
                label: isFavorite ? "Saved" : "Save",
                color: isFavorite ? .pink : .white.opacity(0.7)
            ) {
                toggleFavorite()
            }
            
            // Share button
            ActionButton(
                icon: "square.and.arrow.up",
                label: "Share",
                color: .white.opacity(0.7)
            ) {
                showShareSheet = true
            }
            
            // Copy button
            ActionButton(
                icon: "doc.on.doc",
                label: "Copy",
                color: .white.opacity(0.7)
            ) {
                copyVerse()
            }
        }
        .padding(.top, 32)
        .opacity(animateIn ? 1 : 0)
        .sheet(isPresented: $showShareSheet) {
            if let verse = currentVerse {
                ShareSheet(text: "\"\(verse.text)\"\n\n— \(verse.reference)")
            }
        }
    }
    
    // MARK: - Favorites Hint
    private var favoritesHint: some View {
        NavigationLink {
            FavoriteVersesView()
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
                
                Text("View \(savedVerses.filter(\.isFavorite).count) saved verses")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
        }
        .opacity(animateIn ? 1 : 0)
    }
    
    // MARK: - Helper Methods
    
    private func loadVerseOfDay() {
        currentVerse = VerseLibrary.getVerseOfDay()
        
        // Check if already saved
        let today = Calendar.current.startOfDay(for: Date())
        isFavorite = savedVerses.contains { 
            Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isFavorite
        }
    }
    
    private func refreshVerse() {
        withAnimation(.easeOut(duration: 0.3)) {
            animateIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentVerse = VerseLibrary.getRandomVerse()
            isFavorite = false
            
            withAnimation(.easeOut(duration: 0.5)) {
                animateIn = true
            }
        }
    }
    
    private func toggleFavorite() {
        guard let verse = currentVerse else { return }
        
        // Check if verse already exists
        if let existing = savedVerses.first(where: { $0.text == verse.text }) {
            existing.isFavorite.toggle()
            isFavorite = existing.isFavorite
        } else {
            // Create new saved verse
            let newVerse = VerseOfDay(
                text: verse.text,
                reference: verse.reference,
                date: Date(),
                isFavorite: true
            )
            modelContext.insert(newVerse)
            isFavorite = true
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func copyVerse() {
        guard let verse = currentVerse else { return }
        UIPasteboard.general.string = "\"\(verse.text)\"\n\n— \(verse.reference)"
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Supporting Views

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
                    .foregroundColor(color)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(color)
            }
            .frame(width: 70)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Favorite Verses View
struct FavoriteVersesView: View {
    @Query(filter: #Predicate<VerseOfDay> { $0.isFavorite }, sort: \VerseOfDay.date, order: .reverse) 
    private var favoriteVerses: [VerseOfDay]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            if favoriteVerses.isEmpty {
                ContentUnavailableView(
                    "No Saved Verses",
                    systemImage: "heart.slash",
                    description: Text("Tap the heart icon to save verses you want to remember")
                )
            } else {
                ForEach(favoriteVerses) { verse in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verse.text)
                            .font(.body)
                        
                        Text(verse.reference)
                            .font(.caption)
                            .foregroundColor(.indigo)
                            .fontWeight(.semibold)
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: deleteVerses)
            }
        }
        .navigationTitle("Saved Verses")
    }
    
    private func deleteVerses(at offsets: IndexSet) {
        for index in offsets {
            let verse = favoriteVerses[index]
            verse.isFavorite = false
        }
    }
}

// MARK: - Preview
#Preview {
    VerseView()
}
