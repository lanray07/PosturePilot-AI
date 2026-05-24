import Foundation
import SwiftData

@Model
final class FocusSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var modeRawValue: String
    var duration: TimeInterval
    var postureAlerts: Int
    var completed: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        mode: FocusMode,
        duration: TimeInterval,
        postureAlerts: Int,
        completed: Bool,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.modeRawValue = mode.rawValue
        self.duration = duration
        self.postureAlerts = postureAlerts
        self.completed = completed
        self.createdAt = createdAt
    }

    var mode: FocusMode {
        get { FocusMode(rawValue: modeRawValue) ?? .work }
        set { modeRawValue = newValue.rawValue }
    }
}
