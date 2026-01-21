import Foundation
import Combine
import FamilyControls
import ManagedSettings

@MainActor
final class AppBlockingManager: ObservableObject {
    @Published private(set) var authorizationStatus: AuthorizationStatus = AuthorizationCenter.shared.authorizationStatus
    @Published private(set) var isShieldingActive: Bool = false

    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("PrayerLockStore"))

    func refreshAuthorizationStatus() async {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    }

    func applyShield(selection: FamilyActivitySelection) {
        // Apps
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens

        // Categories (optional)
        if selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = nil
        } else {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        // Web domains (optional)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        isShieldingActive = true
    }

    func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        isShieldingActive = false
    }
}

