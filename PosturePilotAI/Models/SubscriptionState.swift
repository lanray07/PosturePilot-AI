import Foundation
import SwiftData

@Model
final class SubscriptionState: Identifiable {
    @Attribute(.unique) var id: UUID
    var planRawValue: String
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan,
        isActive: Bool,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.planRawValue = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRawValue) ?? .free }
        set { planRawValue = newValue.rawValue }
    }
}
