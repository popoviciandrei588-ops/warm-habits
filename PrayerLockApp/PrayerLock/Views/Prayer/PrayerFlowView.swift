import SwiftUI

struct PrayerFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var blockingManager: BlockingManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep: PrayerStep = .mood
    @State private var selectedMood: MoodType?
    @State private var moodNote: String = ""
    @State private var generatedPrayer: String = ""
    @State private var isComplete = false
    
    enum PrayerStep {
        case mood
        case prayer
        case timer
        case complete
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack {
                // Close button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Step indicator
                    HStack(spacing: PLSpacing.xs) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(stepColor(for: index))
                                .frame(width: index == stepIndex ? 24 : 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, PLSpacing.md)
                .padding(.top, PLSpacing.md)
                
                // Content
                switch currentStep {
                case .mood:
                    MoodSelectionView(
                        selectedMood: $selectedMood,
                        moodNote: $moodNote,
                        onContinue: {
                            withAnimation(.plSpring) {
                                generatePrayer()
                                currentStep = .prayer
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                case .prayer:
                    PrayerDisplayView(
                        prayer: generatedPrayer,
                        mood: selectedMood,
                        onContinue: {
                            withAnimation(.plSpring) {
                                currentStep = .timer
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                case .timer:
                    TimerView(
                        duration: appState.prayerDuration,
                        onComplete: {
                            withAnimation(.plSpring) {
                                currentStep = .complete
                                handleCompletion()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    
                case .complete:
                    CompletionView(
                        unlockMinutes: appState.unlockWindow,
                        onDismiss: { dismiss() }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    private var stepIndex: Int {
        switch currentStep {
        case .mood: return 0
        case .prayer: return 1
        case .timer: return 2
        case .complete: return 2
        }
    }
    
    private func stepColor(for index: Int) -> Color {
        if index < stepIndex {
            return Color(hex: "10B981")
        } else if index == stepIndex {
            return .white
        } else {
            return .white.opacity(0.3)
        }
    }
    
    private func generatePrayer() {
        guard let mood = selectedMood else { return }
        generatedPrayer = PrayerService.generatePrayer(
            for: mood,
            customNote: moodNote.isEmpty ? nil : moodNote
        )
    }
    
    private func handleCompletion() {
        guard let mood = selectedMood else { return }
        
        // Save session
        let session = PrayerSession(
            duration: appState.prayerDuration,
            mood: mood.rawValue,
            moodNote: moodNote.isEmpty ? nil : moodNote,
            prayerText: generatedPrayer,
            completed: true
        )
        modelContext.insert(session)
        
        // Unlock apps
        appState.unlockApps()
        blockingManager.temporarilyUnblock(for: appState.unlockWindow)
    }
}

#Preview {
    PrayerFlowView()
        .environmentObject(AppState())
        .environmentObject(BlockingManager())
}
