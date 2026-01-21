import Foundation
import FamilyControls

extension BlockSelection {
    var decodedSelection: FamilyActivitySelection {
        get {
            guard let selectionData else { return FamilyActivitySelection() }
            do {
                return try JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData)
            } catch {
                return FamilyActivitySelection()
            }
        }
        set {
            updatedAt = .now
            do {
                selectionData = try JSONEncoder().encode(newValue)
            } catch {
                selectionData = nil
            }
        }
    }
}

