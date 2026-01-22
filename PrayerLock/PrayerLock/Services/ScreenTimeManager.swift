import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

@MainActor
class ScreenTimeManager: ObservableObject {
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    @Published var isBlocking: Bool = false
    @Published var errorMessage: String?
    
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    
    enum AuthorizationStatus {
        case notDetermined
        case authorized
        case denied
    }
    
    init() {
        checkAuthorizationStatus()
        loadSavedSelection()
    }
    
    func requestAuthorization() async {
        do {
            try await center.requestAuthorization(for: .individual)
            authorizationStatus = .authorized
            errorMessage = nil
        } catch {
            authorizationStatus = .denied
            errorMessage = "Screen Time permission is required to block apps. Please enable it in Settings."
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func checkAuthorizationStatus() {
        switch center.authorizationStatus {
        case .notDetermined:
            authorizationStatus = .notDetermined
        case .approved:
            authorizationStatus = .authorized
        case .denied:
            authorizationStatus = .denied
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
    
    func saveSelection(_ selection: FamilyActivitySelection) {
        selectedApps = selection
        
        // Save to UserDefaults
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(selection) {
            UserDefaults.standard.set(data, forKey: "prayerlock.selectedApps")
        }
    }
    
    private func loadSavedSelection() {
        guard let data = UserDefaults.standard.data(forKey: "prayerlock.selectedApps") else { return }
        
        let decoder = PropertyListDecoder()
        if let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            selectedApps = selection
        }
    }
    
    func enableBlocking() {
        guard authorizationStatus == .authorized else {
            errorMessage = "Please grant Screen Time permission first."
            return
        }
        
        let applications = selectedApps.applicationTokens
        let categories = selectedApps.categoryTokens
        
        if applications.isEmpty && categories.isEmpty {
            errorMessage = "Please select at least one app to block."
            return
        }
        
        store.shield.applications = applications
        store.shield.applicationCategories = .specific(categories)
        
        isBlocking = true
        errorMessage = nil
    }
    
    func disableBlocking() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        isBlocking = false
    }
    
    func temporarilyDisableBlocking(for duration: TimeInterval) {
        disableBlocking()
        
        // Re-enable after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.enableBlocking()
        }
    }
    
    var hasSelectedApps: Bool {
        !selectedApps.applicationTokens.isEmpty || !selectedApps.categoryTokens.isEmpty
    }
    
    var selectedAppCount: Int {
        selectedApps.applicationTokens.count + selectedApps.categoryTokens.count
    }
}

// MARK: - Device Activity Monitor Extension Name
extension DeviceActivityName {
    static let prayerActivity = Self("prayerlock.activity")
}

// MARK: - Device Activity Schedule
extension DeviceActivitySchedule {
    static var alwaysActive: DeviceActivitySchedule {
        // Schedule that is always active
        let calendar = Calendar.current
        let startTime = DateComponents(hour: 0, minute: 0)
        let endTime = DateComponents(hour: 23, minute: 59)
        
        return DeviceActivitySchedule(
            intervalStart: startTime,
            intervalEnd: endTime,
            repeats: true
        )
    }
}
