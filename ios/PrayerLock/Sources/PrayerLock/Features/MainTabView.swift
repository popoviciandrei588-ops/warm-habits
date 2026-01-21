import SwiftUI
import SwiftData
import FamilyControls
import UIKit

struct MainTabView: View {
    var body: some View {
        TabView {
            PrayerHomeView()
                .tabItem { Label("Pray", systemImage: "lock.shield") }

            StatsView()
                .tabItem { Label("Journey", systemImage: "chart.line.uptrend.xyaxis") }

            VerseView()
                .tabItem { Label("Verse", systemImage: "book") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct PrayerHomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("Before you scroll, pause and pray.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("Start a short prayer lock to unlock your chosen apps.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                NavigationLink("Begin") {
                    MoodSelectionView()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Prayer Lock")
        }
    }
}

struct StatsView: View {
    @Query(sort: \PrayerSession.startedAt, order: .reverse)
    private var sessions: [PrayerSession]

    @Query(sort: \Streak.longest, order: .reverse)
    private var streaks: [Streak]

    var body: some View {
        NavigationStack {
            List {
                let completed = sessions.filter { $0.didComplete }
                let totalTime = completed.reduce(0) { $0 + $1.durationSeconds }
                let moodCounts = Dictionary(grouping: completed, by: \.moodKey).mapValues(\.count)
                let sortedMoods = moodCounts.keys.sorted { (moodCounts[$0] ?? 0) > (moodCounts[$1] ?? 0) }

                Section("Streak") {
                    let streak = streaks.first
                    StatRow(title: "Current streak", value: "\(streak?.current ?? 0) days")
                    StatRow(title: "Longest streak", value: "\(streak?.longest ?? 0) days")
                }

                Section("Sessions") {
                    StatRow(title: "Total prayers", value: "\(completed.count)")
                    StatRow(title: "Total time prayed", value: "\(formatSeconds(totalTime))")
                }

                Section("By mood") {
                    if sortedMoods.isEmpty {
                        Text("Your mood breakdown will appear after a few prayers.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sortedMoods, id: \.self) { key in
                            let count = moodCounts[key] ?? 0
                            HStack {
                                Text(Mood(rawValue: key)?.title ?? key.capitalized)
                                Spacer()
                                Text("\(count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Recent") {
                    if completed.isEmpty {
                        Text("Complete a prayer lock to start your journey.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(completed.prefix(10), id: \.id) { s in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(Mood(rawValue: s.moodKey)?.title ?? s.moodKey.capitalized)
                                    .font(.headline)
                                Text(s.startedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Journey")
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m == 0 { return "\(s)s" }
        return "\(m)m \(s)s"
    }
}

struct VerseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VerseOfDay.day, order: .reverse)
    private var verses: [VerseOfDay]

    @State private var todays: VerseOfDay?

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                if let verse = todays {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Verse of the day")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("“\(verse.text)”")
                            .font(.title3.weight(.semibold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(verse.reference)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()
                } else {
                    ProgressView()
                        .padding(.top, 40)
                    Spacer()
                }
            }
            .navigationTitle("Verse")
            .task { ensureToday() }
        }
    }

    private func ensureToday() {
        let day = VerseProvider.startOfDay(.now)
        if let existing = verses.first(where: { $0.day == day }) {
            todays = existing
            return
        }

        let v = VerseProvider.verseForToday(.now)
        let record = VerseOfDay(day: day, reference: v.reference, text: v.text)
        modelContext.insert(record)
        todays = record
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appBlockingManager: AppBlockingManager

    @Query(sort: \UserSettings.createdAt, order: .forward)
    private var settings: [UserSettings]

    @Query(sort: \BlockSelection.createdAt, order: .forward)
    private var selections: [BlockSelection]

    @State private var isPickerPresented = false
    @State private var draftSelection = FamilyActivitySelection()
    @State private var selectedPreset: LockPreset = .seconds60
    @State private var customSeconds: Int = 60

    var body: some View {
        NavigationStack {
            List {
                Section("Lock duration") {
                    Picker("Prayer time", selection: $selectedPreset) {
                        ForEach(LockPreset.allCases) { preset in
                            Text(preset.title).tag(preset)
                        }
                    }

                    if selectedPreset == .custom {
                        Stepper(value: $customSeconds, in: 10...600, step: 5) {
                            Text("Custom: \(customSeconds) seconds")
                        }
                    }

                    Toggle("Show verse after prayer", isOn: Binding(
                        get: { settings.first?.showVerseAfterPrayer ?? true },
                        set: { settings.first?.showVerseAfterPrayer = $0 }
                    ))
                }

                Section("App Blocking") {
                    if appBlockingManager.authorizationStatus != .approved {
                        PermissionsFixCard()
                    }

                    Button("Edit blocked apps") {
                        draftSelection = selections.first?.decodedSelection ?? FamilyActivitySelection()
                        isPickerPresented = true
                    }
                    .disabled(appBlockingManager.authorizationStatus != .approved)

                    Button("Re-apply blocking now") {
                        guard let s = selections.first?.decodedSelection else { return }
                        appBlockingManager.applyShield(selection: s)
                    }
                    .disabled(appBlockingManager.authorizationStatus != .approved)

                    Button("Unlock now") {
                        appBlockingManager.clearShield()
                    }
                }

                Section("About") {
                    Text("PrayerLock is a faith-first screen time blocker. Before you scroll, pause, pray, then unlock.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $draftSelection)
            .onChange(of: isPickerPresented) { _, presented in
                // When picker dismisses, persist changes.
                if !presented {
                    selections.first?.decodedSelection = draftSelection
                    // If user already relies on shielding, keep it applied with the new selection.
                    if appBlockingManager.isShieldingActive {
                        appBlockingManager.applyShield(selection: draftSelection)
                    }
                }
            }
            .task {
                await appBlockingManager.refreshAuthorizationStatus()
                hydrateLockPresetFromModel()
            }
            .onChange(of: selectedPreset) { _, _ in
                persistLockSeconds()
            }
            .onChange(of: customSeconds) { _, _ in
                persistLockSeconds()
            }
        }
    }

    private func hydrateLockPresetFromModel() {
        let seconds = settings.first?.lockDurationSeconds ?? 60
        if let preset = LockPreset(persistedSeconds: seconds) {
            selectedPreset = preset
            customSeconds = seconds
        } else {
            selectedPreset = .custom
            customSeconds = seconds
        }
    }

    private func persistLockSeconds() {
        guard let s = settings.first else { return }
        switch selectedPreset {
        case .seconds30: s.lockDurationSeconds = 30
        case .seconds60: s.lockDurationSeconds = 60
        case .seconds90: s.lockDurationSeconds = 90
        case .seconds120: s.lockDurationSeconds = 120
        case .custom: s.lockDurationSeconds = customSeconds
        }
    }
}

private struct StatRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

private enum LockPreset: String, CaseIterable, Identifiable {
    case seconds30
    case seconds60
    case seconds90
    case seconds120
    case custom

    var id: String { rawValue }
    var title: String {
        switch self {
        case .seconds30: return "30 seconds"
        case .seconds60: return "60 seconds (default)"
        case .seconds90: return "90 seconds"
        case .seconds120: return "120 seconds"
        case .custom: return "Custom"
        }
    }

    init?(persistedSeconds: Int) {
        switch persistedSeconds {
        case 30: self = .seconds30
        case 60: self = .seconds60
        case 90: self = .seconds90
        case 120: self = .seconds120
        default: return nil
        }
    }
}

