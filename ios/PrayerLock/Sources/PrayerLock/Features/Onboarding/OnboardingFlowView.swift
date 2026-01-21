import SwiftUI
import SwiftData
import FamilyControls

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appBlockingManager: AppBlockingManager

    @Query(sort: \UserSettings.createdAt, order: .forward)
    private var settings: [UserSettings]

    @Query(sort: \BlockSelection.createdAt, order: .forward)
    private var selections: [BlockSelection]

    private var userSettings: UserSettings { settings.first! }
    private var blockSelection: BlockSelection { selections.first! }

    var body: some View {
        NavigationStack {
            OnboardingIntroStep {
                OnboardingPermissionStep {
                    OnboardingAppSelectionStep(
                        initialSelection: blockSelection.decodedSelection
                    ) { newSelection in
                        blockSelection.decodedSelection = newSelection
                        userSettings.hasCompletedOnboarding = true
                        // Start in “blocked” state after onboarding so the core experience works immediately.
                        appBlockingManager.applyShield(selection: newSelection)
                    }
                }
            }
        }
    }
}

// MARK: - Step 1: Concept

private struct OnboardingIntroStep<Next: View>: View {
    let next: () -> Next

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 10) {
                Text("Make prayer the first response.")
                    .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)

                Text("Phone pings make prayer an afterthought. PrayerLock flips that: before distracting apps open, you pause, pray, then unlock.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(alignment: .leading, spacing: 10) {
                Bullet(text: "Choose the apps that distract you.")
                Bullet(text: "They’ll be blocked until you complete a short, Bible-rooted prayer.")
                Bullet(text: "Pray and lock as many times as you want.")
            }
            .padding(.horizontal, 24)
            .padding(.top, 6)

            Spacer()

            NavigationLink {
                next()
            } label: {
                Text("Get started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Bullet: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.subheadline)
                .padding(.top, 2)
            Text(text)
                .font(.body)
        }
        .foregroundStyle(.primary)
    }
}

// MARK: - Step 2: Permissions

private struct OnboardingPermissionStep<Next: View>: View {
    @EnvironmentObject private var appBlockingManager: AppBlockingManager
    @State private var isRequesting = false
    @State private var showFix = false

    let next: () -> Next

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            VStack(spacing: 10) {
                Text("Enable Screen Time")
                    .font(.title.weight(.semibold))
                Text("To block selected apps, PrayerLock needs Family Controls permission.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if showFix {
                PermissionsFixCard()
                    .padding(.horizontal, 20)
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    Task {
                        isRequesting = true
                        defer { isRequesting = false }

                        do {
                            try await ScreenTimePermission.requestAuthorization()
                            await appBlockingManager.refreshAuthorizationStatus()
                            showFix = appBlockingManager.authorizationStatus != .approved
                        } catch {
                            await appBlockingManager.refreshAuthorizationStatus()
                            showFix = true
                        }
                    }
                } label: {
                    HStack {
                        if isRequesting { ProgressView().padding(.trailing, 6) }
                        Text("Allow Screen Time access")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                NavigationLink {
                    next()
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(appBlockingManager.authorizationStatus != .approved)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .padding(.top, 10)
        .navigationTitle("Permissions")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await appBlockingManager.refreshAuthorizationStatus()
            showFix = appBlockingManager.authorizationStatus != .approved
        }
    }
}

// MARK: - Step 3: App selection

private struct OnboardingAppSelectionStep: View {
    @EnvironmentObject private var appBlockingManager: AppBlockingManager

    @State private var selection: FamilyActivitySelection
    @State private var isPickerPresented = false

    let onFinish: (FamilyActivitySelection) -> Void

    init(initialSelection: FamilyActivitySelection, onFinish: @escaping (FamilyActivitySelection) -> Void) {
        _selection = State(initialValue: initialSelection)
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 14) {
            Spacer()

            VStack(spacing: 10) {
                Text("Choose apps to block")
                    .font(.title.weight(.semibold))
                Text("These apps will be shielded until you complete a prayer lock.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            VStack(spacing: 10) {
                Button {
                    isPickerPresented = true
                } label: {
                    Text("Select apps")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Text(summaryText(for: selection))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.horizontal, 20)

            Spacer()

            Button {
                onFinish(selection)
            } label: {
                Text("Finish onboarding")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .disabled(selection.applicationTokens.isEmpty && selection.categoryTokens.isEmpty && selection.webDomainTokens.isEmpty)
        }
        .navigationTitle("App Selection")
        .navigationBarTitleDisplayMode(.inline)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
        .task {
            await appBlockingManager.refreshAuthorizationStatus()
        }
    }

    private func summaryText(for selection: FamilyActivitySelection) -> String {
        let apps = selection.applicationTokens.count
        let cats = selection.categoryTokens.count
        let webs = selection.webDomainTokens.count
        if apps == 0 && cats == 0 && webs == 0 {
            return "No apps selected yet."
        }
        return "Selected: \(apps) apps • \(cats) categories • \(webs) websites"
    }
}

