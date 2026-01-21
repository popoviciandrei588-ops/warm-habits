import SwiftUI
import SwiftData

struct PrayerTimerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var appBlockingManager: AppBlockingManager

    @Query(sort: \UserSettings.createdAt, order: .forward)
    private var settings: [UserSettings]

    @Query(sort: \BlockSelection.createdAt, order: .forward)
    private var selections: [BlockSelection]

    let mood: Mood
    let freeText: String?

    @State private var prayerDraft: PrayerDraft?
    @State private var sessionID: UUID?
    @State private var remainingSeconds: Int = 60
    @State private var isRunning: Bool = true
    @State private var showComplete: Bool = false

    private let composer = PrayerComposer(mode: .offlineTemplates)

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Pause. Breathe. Pray.")
                    .font(.title2.weight(.semibold))
                Text("Your apps stay locked until this prayer completes.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 8)

            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 18)
                    .frame(width: 220, height: 220)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(.tint, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.25), value: progress)
                    .frame(width: 220, height: 220)

                VStack(spacing: 4) {
                    Text(timeString(remainingSeconds))
                        .font(.system(size: 44, weight: .semibold, design: .rounded))
                    Text(isRunning ? "praying" : "paused")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 6)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let draft = prayerDraft {
                        Text(draft.text)
                            .font(.body)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                        if let ref = draft.verseReference {
                            Text("Rooted in \(ref)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                        }
                    } else {
                        ProgressView("Preparing your prayer…")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
            }

            HStack(spacing: 10) {
                Button {
                    isRunning.toggle()
                } label: {
                    Text(isRunning ? "Pause" : "Resume")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    // Intentionally does NOT unlock. Edge-case requirement:
                    // leaving early keeps shielding on until they complete a new prayer.
                    isRunning = false
                } label: {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .navigationTitle("Prayer Lock")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showComplete) {
            PrayerCompleteView()
        }
        .task {
            await prepareSessionIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                isRunning = false
            }
        }
        .onReceive(timer) { _ in
            guard isRunning else { return }
            tick()
        }
    }

    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }

    private var totalSeconds: Int {
        let configured = settings.first?.lockDurationSeconds ?? 60
        return max(5, configured)
    }

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    private func prepareSessionIfNeeded() async {
        if prayerDraft == nil {
            prayerDraft = await composer.compose(mood: mood, freeText: freeText)
        }
        if sessionID == nil, let draft = prayerDraft {
            remainingSeconds = totalSeconds

            let session = PrayerSession(
                moodKey: mood.rawValue,
                moodFreeText: freeText,
                durationSeconds: totalSeconds,
                prayerText: draft.text,
                verseReference: draft.verseReference,
                didComplete: false
            )
            modelContext.insert(session)
            sessionID = session.id
            appState.beginPrayer(sessionID: session.id, durationSeconds: totalSeconds)

            // Ensure shielding is on while praying.
            if let selection = selections.first?.decodedSelection {
                appBlockingManager.applyShield(selection: selection)
            }
        }
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        appState.updateRemaining(remainingSeconds)

        if remainingSeconds == 0 {
            complete()
        }
    }

    private func complete() {
        isRunning = false

        if let id = sessionID {
            // Mark prayer complete in SwiftData.
            // NOTE: In a fuller implementation, we’d `@Query` session by id or fetch.
            // Here we do a small fetch for correctness.
            let fetch = FetchDescriptor<PrayerSession>(predicate: #Predicate { $0.id == id })
            if let session = try? modelContext.fetch(fetch).first {
                session.didComplete = true
                session.completedAt = .now
            }
        }

        // Update streak + analytics aggregates.
        StreakService.registerCompletedPrayer(on: .now, modelContext: modelContext)

        // Unlock (unshield) only when the timer completes.
        appBlockingManager.clearShield()
        appState.completePrayer()
        showComplete = true
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct PrayerCompleteView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Unlocked")
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
            Text("Your selected apps are unblocked. Come back anytime to lock again.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            NavigationLink {
                VerseView()
            } label: {
                Text("Read today’s verse")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal, 20)

            Button {
                // “Repeatable”: user can lock as many times as they want.
                appState.resetToIdle()
                dismiss()
            } label: {
                Text("Lock again")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)

            Button {
                // Keep unlocked; just go back.
                dismiss()
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.vertical, 24)
        .navigationTitle("Complete")
        .navigationBarTitleDisplayMode(.inline)
    }
}

