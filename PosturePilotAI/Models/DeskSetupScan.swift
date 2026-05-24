import Foundation
import SwiftData

@Model
final class DeskSetupScan: Identifiable {
    @Attribute(.unique) var id: UUID
    var setupScore: Int
    var recommendations: [String]
    var workspaceNotes: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        setupScore: Int,
        recommendations: [String],
        workspaceNotes: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.setupScore = setupScore
        self.recommendations = recommendations
        self.workspaceNotes = workspaceNotes
        self.createdAt = createdAt
    }
}
