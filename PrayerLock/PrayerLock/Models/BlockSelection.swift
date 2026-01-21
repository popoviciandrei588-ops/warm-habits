import Foundation
import SwiftData
import FamilyControls

/// Model representing the user's app blocking selection
@Model
final class BlockSelection {
    /// Unique identifier
    var id: UUID
    
    /// Date when this selection was created
    var createdAt: Date
    
    /// Date when this selection was last modified
    var updatedAt: Date
    
    /// Whether blocking is currently active
    var isActive: Bool
    
    /// Serialized app tokens (stored as Data since FamilyActivitySelection isn't directly Codable for SwiftData)
    var selectionData: Data?
    
    /// Number of apps selected (for display purposes)
    var selectedAppCount: Int
    
    /// Number of categories selected (for display purposes)
    var selectedCategoryCount: Int
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = false,
        selectionData: Data? = nil,
        selectedAppCount: Int = 0,
        selectedCategoryCount: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
        self.selectionData = selectionData
        self.selectedAppCount = selectedAppCount
        self.selectedCategoryCount = selectedCategoryCount
    }
    
    /// Update the selection counts
    func updateCounts(apps: Int, categories: Int) {
        self.selectedAppCount = apps
        self.selectedCategoryCount = categories
        self.updatedAt = Date()
    }
}

// MARK: - Selection Storage Helper
extension BlockSelection {
    /// Store a FamilyActivitySelection
    func storeSelection(_ selection: FamilyActivitySelection) {
        do {
            let encoder = PropertyListEncoder()
            self.selectionData = try encoder.encode(selection)
            self.selectedAppCount = selection.applicationTokens.count
            self.selectedCategoryCount = selection.categoryTokens.count
            self.updatedAt = Date()
        } catch {
            print("Failed to encode selection: \(error)")
        }
    }
    
    /// Retrieve the stored FamilyActivitySelection
    func retrieveSelection() -> FamilyActivitySelection? {
        guard let data = selectionData else { return nil }
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to decode selection: \(error)")
            return nil
        }
    }
}
