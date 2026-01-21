import Foundation
import SwiftData

@Model
final class UserSettings {
    var isPremium: Bool
    var defaultDuration: Int // seconds
    var isOnboardingCompleted: Bool
    
    init(isPremium: Bool = false, defaultDuration: Int = 60, isOnboardingCompleted: Bool = false) {
        self.isPremium = isPremium
        self.defaultDuration = defaultDuration
        self.isOnboardingCompleted = isOnboardingCompleted
    }
}
