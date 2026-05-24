import Foundation
import SwiftData

@Model
final class StretchRoutine: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryRawValue: String
    var duration: TimeInterval
    var completed: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: StretchCategory,
        duration: TimeInterval,
        completed: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.categoryRawValue = category.rawValue
        self.duration = duration
        self.completed = completed
        self.createdAt = createdAt
    }

    var category: StretchCategory {
        get { StretchCategory(rawValue: categoryRawValue) ?? .standingReset }
        set { categoryRawValue = newValue.rawValue }
    }
}
