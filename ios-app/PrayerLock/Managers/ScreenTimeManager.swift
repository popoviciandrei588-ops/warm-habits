import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI

class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()
    
    @Published var activitySelection = FamilyActivitySelection()
    @Published var isBlockingEnabled = false
    
    private let store = ManagedSettingsStore()
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("Failed to request authorization: \(error)")
        }
    }
    
    func saveSelection() {
        // Just saving the selection to the property, in a real app persist to UserDefaults or Disk
        if isBlockingEnabled {
            activateShield()
        }
    }
    
    func toggleBlocking(_ enabled: Bool) {
        isBlockingEnabled = enabled
        if enabled {
            activateShield()
        } else {
            deactivateShield()
        }
    }
    
    func activateShield() {
        let applications = activitySelection.applicationTokens
        let categories = activitySelection.categoryTokens
        let webDomains = activitySelection.webDomainTokens
        
        store.shield.applications = applications
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
        store.shield.webDomains = webDomains
    }
    
    func deactivateShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
