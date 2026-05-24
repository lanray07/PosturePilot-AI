import Foundation
import SwiftData

@Model
final class PostureSession: Identifiable {
    @Attribute(.unique) var id: UUID
    var postureScore: Int
    var slouchDetected: Bool
    var headTiltDetected: Bool
    var shoulderImbalanceDetected: Bool
    var leaningDetected: Bool
    var downwardGazeDetected: Bool
    var sittingDuration: TimeInterval
    var summary: String
    var suggestedCorrection: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        postureScore: Int,
        slouchDetected: Bool,
        headTiltDetected: Bool,
        shoulderImbalanceDetected: Bool,
        leaningDetected: Bool = false,
        downwardGazeDetected: Bool = false,
        sittingDuration: TimeInterval,
        summary: String,
        suggestedCorrection: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.postureScore = postureScore
        self.slouchDetected = slouchDetected
        self.headTiltDetected = headTiltDetected
        self.shoulderImbalanceDetected = shoulderImbalanceDetected
        self.leaningDetected = leaningDetected
        self.downwardGazeDetected = downwardGazeDetected
        self.sittingDuration = sittingDuration
        self.summary = summary
        self.suggestedCorrection = suggestedCorrection
        self.createdAt = createdAt
    }
}
