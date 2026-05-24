import Foundation
import SwiftData

@Model
final class Achievement: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var achievementDescription: String
    var icon: String
    var unlocked: Bool
    var unlockedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        icon: String,
        unlocked: Bool = false,
        unlockedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.achievementDescription = description
        self.icon = icon
        self.unlocked = unlocked
        self.unlockedAt = unlockedAt
    }
}
