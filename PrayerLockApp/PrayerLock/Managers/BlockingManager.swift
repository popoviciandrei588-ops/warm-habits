import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@MainActor
class BlockingManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isBlocking: Bool = false
    @Published var showAppPicker: Bool = false
    
    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    
    // MARK: - Initialization
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    func checkAuthorizationStatus() async {
        authorizationStatus = center.authorizationStatus
    }
    
    func requestAuthorization() async throws {
        try await center.requestAuthorization(for: .individual)
        await checkAuthorizationStatus()
    }
    
    var isAuthorized: Bool {
        authorizationStatus == .approved
    }
    
    // MARK: - App Selection
    func updateSelectedApps(_ selection: FamilyActivitySelection) {
        selectedApps = selection
        saveSelection()
        
        if isBlocking {
            applyShielding()
        }
    }
    
    var hasSelectedApps: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }
    
    var selectedAppsCount: Int {
        selectedApps.applicationTokens.count + selectedApps.categoryTokens.count
    }
    
    // MARK: - Shielding
    func startBlocking() {
        guard isAuthorized && hasSelectedApps else { return }
        isBlocking = true
        applyShielding()
        saveBlockingState()
    }
    
    func stopBlocking() {
        isBlocking = false
        removeShielding()
        saveBlockingState()
    }
    
    func temporarilyUnblock(for minutes: Int) {
        removeShielding()
        
        // Schedule re-blocking after the unlock window
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(minutes * 60)) { [weak self] in
            self?.applyShielding()
        }
    }
    
    private func applyShielding() {
        store.shield.applications = selectedApps.applicationTokens.isEmpty ? nil : selectedApps.applicationTokens
        store.shield.applicationCategories = selectedApps.categoryTokens.isEmpty ? nil : .specific(selectedApps.categoryTokens)
        
        // Customize shield appearance
        store.shield.webDomains = nil
    }
    
    private func removeShielding() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    // MARK: - Persistence
    private func saveSelection() {
        if let encoded = try? JSONEncoder().encode(selectedApps) {
            UserDefaults.standard.set(encoded, forKey: "selectedApps")
        }
    }
    
    private func loadSelection() {
        if let data = UserDefaults.standard.data(forKey: "selectedApps"),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selectedApps = decoded
        }
    }
    
    private func saveBlockingState() {
        UserDefaults.standard.set(isBlocking, forKey: "isBlocking")
    }
    
    private func loadBlockingState() {
        isBlocking = UserDefaults.standard.bool(forKey: "isBlocking")
        if isBlocking {
            applyShielding()
        }
    }
    
    func loadSavedState() {
        loadSelection()
        loadBlockingState()
    }
}

// MARK: - Authorization Status Extension
extension AuthorizationStatus {
    var displayText: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied"
        case .approved:
            return "Approved"
        @unknown default:
            return "Unknown"
        }
    }
}
