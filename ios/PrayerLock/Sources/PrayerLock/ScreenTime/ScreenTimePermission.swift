import Foundation
import FamilyControls

enum ScreenTimePermission {
    static func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    static var status: AuthorizationStatus {
        AuthorizationCenter.shared.authorizationStatus
    }
}

