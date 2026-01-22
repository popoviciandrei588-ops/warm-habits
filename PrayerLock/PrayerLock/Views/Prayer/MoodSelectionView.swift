import SwiftUI

struct MoodSelectionView: View {
    @Binding var selectedMood: MoodType?
    @Binding var moodNote: String
    @State private var appear = false
    @FocusState private var isNoteFocused: Bool
    
    let onContinue: () -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: PLSpacing.xl) {
            Spacer()
            
            // Header
            VStack(spacing: PLSpacing.sm) {
                Text("How are you feeling?")
                    .font(PLTypography.displaySmall)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                
                Text("Choose what resonates with you right now")
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
            }
            
            // Mood grid
            LazyVGrid(columns: columns, spacing: PLSpacing.sm) {
                ForEach(MoodType.allCases) { mood in
                    MoodChip(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.plSpring) {
                            selectedMood = mood
                        }
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                }
            }
            .padding(.horizontal, PLSpacing.md)
            
            // Optional note
            VStack(alignment: .leading, spacing: PLSpacing.xs) {
                Text("Anything specific? (optional)")
                    .font(PLTypography.labelMedium)
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Share what's on your heart...", text: $moodNote, axis: .vertical)
                    .font(PLTypography.bodyMedium)
                    .foregroundColor(.white)
                    .padding(PLSpacing.md)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: PLRadius.md))
                    .lineLimit(2...4)
                    .focused($isNoteFocused)
            }
            .padding(.horizontal, PLSpacing.lg)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            
            Spacer()
            
            // Continue button
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(PLTypography.titleMedium)
                    .foregroundColor(Color(hex: "1E3A5F"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PLSpacing.md)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
            }
            .disabled(selectedMood == nil)
            .opacity(selectedMood != nil ? 1 : 0.5)
            .padding(.horizontal, PLSpacing.lg)
            .padding(.bottom, PLSpacing.xl)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appear = true
            }
        }
        .onTapGesture {
            isNoteFocused = false
        }
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        MoodSelectionView(
            selectedMood: .constant(.anxious),
            moodNote: .constant("")
        ) {}
    }
}
