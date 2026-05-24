import Foundation
import SwiftData

@MainActor
final class CameraPostureViewModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case requestingPermission
        case analyzing
        case complete
        case failed(String)
    }

    @Published var phase: Phase = .idle
    @Published var result: PostureAnalysisResult?
    @Published var latestSignal = PostureSignal.calmSample

    var isWorking: Bool {
        phase == .requestingPermission || phase == .analyzing
    }

    func runCheck(
        cameraService: CameraPostureService,
        sittingTracker: SittingTrackerService,
        aiService: any AIService,
        context: ModelContext
    ) async {
        phase = .requestingPermission

        guard await cameraService.requestPermission() else {
            phase = .failed("Camera permission is needed for posture checks. You can still use reminders and routines.")
            return
        }

        cameraService.startPlaceholderCamera()
        phase = .analyzing
        latestSignal = cameraService.capturePlaceholderMetrics()

        do {
            let input = PostureAnalysisInput(
                sittingDurationMinutes: Int(sittingTracker.currentSittingDuration / 60),
                metrics: latestSignal,
                workStyle: "desk",
                goal: "improve sitting posture"
            )
            let analysis = try await aiService.analyzePosture(input)
            result = analysis

            let session = PostureSession(
                postureScore: analysis.postureScore,
                slouchDetected: latestSignal.slouchConfidence > 0.42,
                headTiltDetected: latestSignal.headTiltConfidence > 0.38,
                shoulderImbalanceDetected: latestSignal.shoulderImbalanceConfidence > 0.40,
                leaningDetected: latestSignal.leaningConfidence > 0.38,
                downwardGazeDetected: latestSignal.downwardGazeConfidence > 0.44,
                sittingDuration: sittingTracker.currentSittingDuration,
                summary: analysis.summary,
                suggestedCorrection: analysis.suggestedCorrection
            )
            context.insert(session)
            try? context.save()
            phase = .complete
        } catch {
            phase = .failed(error.localizedDescription)
        }

        cameraService.stopPlaceholderCamera()
    }
}
