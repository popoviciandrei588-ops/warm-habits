import SwiftUI

/// View for selecting the user's current mood/feeling before prayer
struct MoodSelectionView: View {
    @State private var selectedMood: Mood?
    @State private var customText: String = ""
    @State private var showPrayerTimer = false
    @FocusState private var isTextFieldFocused: Bool
    
    var onMoodSelected: ((Mood, String?) -> Void)?
    
    // Group moods into categories for better organization
    private let moodGroups: [(title: String, moods: [Mood])] = [
        ("Positive", [.grateful, .joyful, .hopeful, .peaceful, .thankful, .content, .excited]),
        ("Challenging", [.anxious, .sad, .stressed, .frustrated, .overwhelmed, .lonely, .fearful, .angry, .confused])
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.15, green: 0.12, blue: 0.22)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header
                        headerSection
                        
                        // Mood selection
                        moodSelectionSection
                        
                        // Custom text input
                        customTextSection
                        
                        // Continue button
                        continueButton
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("How Are You Feeling?")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .fullScreenCover(isPresented: $showPrayerTimer) {
                if let mood = selectedMood {
                    PrayerTimerView(
                        mood: mood,
                        customText: customText.isEmpty ? nil : customText
                    )
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🤍")
                .font(.system(size: 50))
            
            Text("Tell God how you feel today")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Select the emotion that best describes your heart right now")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Mood Selection Section
    private var moodSelectionSection: some View {
        VStack(spacing: 20) {
            ForEach(moodGroups, id: \.title) { group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.leading, 4)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(group.moods) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: selectedMood == mood,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedMood = mood
                                    }
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Text Section
    private var customTextSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Anything specific on your heart?")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            TextField("Optional: Share what's on your mind...", text: $customText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .focused($isTextFieldFocused)
                .lineLimit(3...6)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button(action: {
            if let mood = selectedMood {
                onMoodSelected?(mood, customText.isEmpty ? nil : customText)
                showPrayerTimer = true
            }
        }) {
            HStack {
                Text("Begin Prayer")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Group {
                    if selectedMood != nil {
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
            )
            .cornerRadius(14)
        }
        .disabled(selectedMood == nil)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                
                Text(mood.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.indigo.opacity(0.4) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.indigo : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    MoodSelectionView()
}
