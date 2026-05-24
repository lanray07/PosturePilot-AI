import Foundation

struct PostureSignal: Codable, Sendable {
    var slouchConfidence: Double
    var headTiltConfidence: Double
    var shoulderImbalanceConfidence: Double
    var leaningConfidence: Double
    var downwardGazeConfidence: Double

    static let calmSample = PostureSignal(
        slouchConfidence: 0.24,
        headTiltConfidence: 0.18,
        shoulderImbalanceConfidence: 0.21,
        leaningConfidence: 0.16,
        downwardGazeConfidence: 0.20
    )
}

struct PostureAnalysisInput: Codable, Sendable {
    var sittingDurationMinutes: Int
    var metrics: PostureSignal
    var workStyle: String
    var goal: String
}

struct PostureAnalysisResult: Codable, Sendable {
    var postureScore: Int
    var summary: String
    var suggestedCorrection: String
    var deskSetupTips: [String]
    var movementReminder: String
    var stretchSuggestions: [String]
}

struct ErgonomicSuggestionResult: Codable, Sendable {
    var setupScore: Int
    var summary: String
    var recommendations: [String]
}

struct PostureInsight: Identifiable, Codable, Sendable {
    var id = UUID()
    var title: String
    var detail: String
    var scoreDelta: Int
}

struct StretchRecommendation: Identifiable, Codable, Sendable {
    var id = UUID()
    var title: String
    var category: String
    var durationSeconds: Int
}

struct TrendSample: Identifiable, Hashable {
    let id = UUID()
    var label: String
    var value: Int
}
