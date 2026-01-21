import Foundation
import SwiftData

@Model
final class VerseOfDay {
    var id: UUID
    var text: String
    var reference: String
    var dateShown: Date
    
    init(text: String, reference: String, dateShown: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.reference = reference
        self.dateShown = dateShown
    }
}
