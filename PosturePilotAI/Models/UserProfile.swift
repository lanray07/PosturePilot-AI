import Foundation
import SwiftData

@Model
final class UserProfile: Identifiable {
    @Attribute(.unique) var id: UUID
    var workStyleRawValue: String
    var sittingHours: Double
    var postureGoalRawValue: String
    var notificationsEnabled: Bool
    var cameraPermissionRequested: Bool
    var motionPermissionRequested: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        workStyle: WorkStyle,
        sittingHours: Double,
        postureGoal: PostureGoal,
        notificationsEnabled: Bool = true,
        cameraPermissionRequested: Bool = false,
        motionPermissionRequested: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.workStyleRawValue = workStyle.rawValue
        self.sittingHours = sittingHours
        self.postureGoalRawValue = postureGoal.rawValue
        self.notificationsEnabled = notificationsEnabled
        self.cameraPermissionRequested = cameraPermissionRequested
        self.motionPermissionRequested = motionPermissionRequested
        self.createdAt = createdAt
    }

    var workStyle: WorkStyle {
        get { WorkStyle(rawValue: workStyleRawValue) ?? .remote }
        set { workStyleRawValue = newValue.rawValue }
    }

    var postureGoal: PostureGoal {
        get { PostureGoal(rawValue: postureGoalRawValue) ?? .improveSittingPosture }
        set { postureGoalRawValue = newValue.rawValue }
    }
}
