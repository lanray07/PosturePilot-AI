import Foundation

protocol AIService {
    func analyzePosture(_ input: PostureAnalysisInput) async throws -> PostureAnalysisResult
    func generateErgonomicSuggestions(notes: String) async throws -> ErgonomicSuggestionResult
    func generatePostureInsights(from sessions: [PostureSession]) async throws -> [PostureInsight]
    func generateStretchRecommendations(for category: StretchCategory?) async throws -> [StretchRecommendation]
}

struct MockAIService: AIService {
    func analyzePosture(_ input: PostureAnalysisInput) async throws -> PostureAnalysisResult {
        try await Task.sleep(nanoseconds: 450_000_000)

        let sittingPenalty = min(18, input.sittingDurationMinutes / 18)
        let signalPenalty = Int(
            input.metrics.slouchConfidence * 16
            + input.metrics.headTiltConfidence * 12
            + input.metrics.shoulderImbalanceConfidence * 10
            + input.metrics.leaningConfidence * 8
            + input.metrics.downwardGazeConfidence * 10
        )
        let score = max(52, min(98, 94 - sittingPenalty - signalPenalty))

        var observations: [String] = []
        if input.metrics.slouchConfidence > 0.42 {
            observations.append("possible slouch detected")
        }
        if input.metrics.headTiltConfidence > 0.38 {
            observations.append("possible neck strain posture")
        }
        if input.metrics.shoulderImbalanceConfidence > 0.40 {
            observations.append("possible shoulder imbalance")
        }
        if input.metrics.downwardGazeConfidence > 0.44 {
            observations.append("prolonged downward gaze may be present")
        }

        let summary = observations.isEmpty
            ? "Your posture check looks steady. Keep your screen near eye level and take movement breaks."
            : "PosturePilot noticed \(observations.joined(separator: ", ")). This is an informational posture cue, not a medical assessment."

        return PostureAnalysisResult(
            postureScore: score,
            summary: summary,
            suggestedCorrection: "Consider lifting your chest gently, relaxing your shoulders, and bringing your screen closer to eye level.",
            deskSetupTips: [
                "Consider adjusting screen height so the top third of the display is near eye level.",
                "Keep keyboard and mouse close enough that elbows can stay relaxed.",
                "Try placing both feet flat or supported while seated."
            ],
            movementReminder: "If you have been sitting for a while, consider a 60-second standing reset.",
            stretchSuggestions: [
                "Neck glide",
                "Shoulder roll",
                "Standing reach"
            ]
        )
    }

    func generateErgonomicSuggestions(notes: String) async throws -> ErgonomicSuggestionResult {
        try await Task.sleep(nanoseconds: 400_000_000)

        let normalizedNotes = notes.lowercased()
        var recommendations = [
            "Consider placing the monitor directly in front of you with the top third near eye level.",
            "Keep the chair close enough that your elbows can rest near your sides.",
            "Use soft front or side lighting to reduce screen glare.",
            "Keep the keyboard and mouse on the same surface and within easy reach."
        ]

        if normalizedNotes.contains("laptop") {
            recommendations.append("If using a laptop for long sessions, consider a stand plus external keyboard and mouse.")
        }
        if normalizedNotes.contains("low") || normalizedNotes.contains("neck") {
            recommendations.append("A raised screen position may reduce the need for a downward gaze posture.")
        }

        return ErgonomicSuggestionResult(
            setupScore: normalizedNotes.isEmpty ? 78 : 84,
            summary: "Here are supportive desk setup ideas based on your workspace notes. These are wellness suggestions, not medical guidance.",
            recommendations: recommendations
        )
    }

    func generatePostureInsights(from sessions: [PostureSession]) async throws -> [PostureInsight] {
        try await Task.sleep(nanoseconds: 250_000_000)

        guard !sessions.isEmpty else {
            return [
                PostureInsight(
                    title: "Start with one check",
                    detail: "Run a camera posture check to create your first trend point.",
                    scoreDelta: 0
                )
            ]
        }

        let average = sessions.map(\.postureScore).reduce(0, +) / max(1, sessions.count)
        let alertCount = sessions.filter { $0.slouchDetected || $0.headTiltDetected || $0.shoulderImbalanceDetected }.count

        return [
            PostureInsight(
                title: "Average posture score",
                detail: "Your recent average is \(average). Small, regular adjustments matter more than perfect posture.",
                scoreDelta: average - 75
            ),
            PostureInsight(
                title: "Pattern awareness",
                detail: "\(alertCount) recent checks included possible posture cues. Consider a short reset between focus blocks.",
                scoreDelta: -alertCount
            )
        ]
    }

    func generateStretchRecommendations(for category: StretchCategory?) async throws -> [StretchRecommendation] {
        try await Task.sleep(nanoseconds: 220_000_000)

        let selected = category ?? .deskDecompression
        return [
            StretchRecommendation(title: "\(selected.title) flow", category: selected.title, durationSeconds: 60),
            StretchRecommendation(title: "Shoulder roll reset", category: StretchCategory.shoulderReset.title, durationSeconds: 45),
            StretchRecommendation(title: "Standing breath reset", category: StretchCategory.standingReset.title, durationSeconds: 90)
        ]
    }
}

struct RemoteAIService: AIService {
    var endpointURL = URL(string: "https://YOUR_BACKEND_URL.com/posturepilot-ai")!
    var urlSession: URLSession = .shared

    func analyzePosture(_ input: PostureAnalysisInput) async throws -> PostureAnalysisResult {
        let response: RemoteAIResponse = try await post(
            module: "posture-analysis",
            sittingDuration: "\(input.sittingDurationMinutes)",
            postureData: [
                "slouchConfidence": "\(input.metrics.slouchConfidence)",
                "headTiltConfidence": "\(input.metrics.headTiltConfidence)",
                "shoulderImbalanceConfidence": "\(input.metrics.shoulderImbalanceConfidence)",
                "leaningConfidence": "\(input.metrics.leaningConfidence)",
                "downwardGazeConfidence": "\(input.metrics.downwardGazeConfidence)"
            ],
            workspaceNotes: "\(input.workStyle), \(input.goal)"
        )

        return PostureAnalysisResult(
            postureScore: response.postureScore,
            summary: response.summary,
            suggestedCorrection: response.recommendations.first ?? "Consider a gentle posture reset.",
            deskSetupTips: response.recommendations,
            movementReminder: response.stretchSuggestions.first ?? "Consider a short movement break.",
            stretchSuggestions: response.stretchSuggestions
        )
    }

    func generateErgonomicSuggestions(notes: String) async throws -> ErgonomicSuggestionResult {
        let response: RemoteAIResponse = try await post(
            module: "ergonomics",
            sittingDuration: "",
            postureData: [:],
            workspaceNotes: notes
        )

        return ErgonomicSuggestionResult(
            setupScore: response.postureScore,
            summary: response.summary,
            recommendations: response.recommendations
        )
    }

    func generatePostureInsights(from sessions: [PostureSession]) async throws -> [PostureInsight] {
        let average = sessions.map(\.postureScore).reduce(0, +) / max(1, sessions.count)
        let response: RemoteAIResponse = try await post(
            module: "insights",
            sittingDuration: "",
            postureData: ["averageScore": "\(average)", "sessionCount": "\(sessions.count)"],
            workspaceNotes: ""
        )

        return response.recommendations.map {
            PostureInsight(title: "AI insight", detail: $0, scoreDelta: 0)
        }
    }

    func generateStretchRecommendations(for category: StretchCategory?) async throws -> [StretchRecommendation] {
        let response: RemoteAIResponse = try await post(
            module: "stretch-recommendations",
            sittingDuration: "",
            postureData: [:],
            workspaceNotes: category?.title ?? ""
        )

        return response.stretchSuggestions.map {
            StretchRecommendation(title: $0, category: category?.title ?? "Recovery", durationSeconds: 60)
        }
    }

    private func post(
        module: String,
        sittingDuration: String,
        postureData: [String: String],
        workspaceNotes: String
    ) async throws -> RemoteAIResponse {
        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            RemoteAIRequest(
                module: module,
                sittingDuration: sittingDuration,
                postureData: postureData,
                workspaceNotes: workspaceNotes
            )
        )

        let (data, response) = try await urlSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.invalidResponse
        }
        return try JSONDecoder().decode(RemoteAIResponse.self, from: data)
    }
}

enum AIServiceError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse: "The posture AI service returned an invalid response."
        }
    }
}

private struct RemoteAIRequest: Codable {
    var module: String
    var sittingDuration: String
    var postureData: [String: String]
    var workspaceNotes: String
}

private struct RemoteAIResponse: Codable {
    var postureScore: Int
    var summary: String
    var recommendations: [String]
    var stretchSuggestions: [String]
}
