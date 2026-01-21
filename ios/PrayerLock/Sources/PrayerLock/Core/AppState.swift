import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum LockState: Equatable {
        case idle
        case praying(sessionID: UUID, remainingSeconds: Int)
        case unlockedRecently
    }

    @Published var lockState: LockState = .idle

    func beginPrayer(sessionID: UUID, durationSeconds: Int) {
        lockState = .praying(sessionID: sessionID, remainingSeconds: durationSeconds)
    }

    func updateRemaining(_ seconds: Int) {
        guard case let .praying(sessionID, _) = lockState else { return }
        lockState = .praying(sessionID: sessionID, remainingSeconds: max(0, seconds))
    }

    func completePrayer() {
        lockState = .unlockedRecently
    }

    func resetToIdle() {
        lockState = .idle
    }
}

