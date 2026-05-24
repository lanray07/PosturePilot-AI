import Foundation
import Combine

@MainActor
final class AppServices: ObservableObject {
    let aiService: any AIService
    let cameraService: CameraPostureService
    let motionService: MotionTrackingService
    let notificationService: NotificationService
    let sittingTracker: SittingTrackerService
    private var cancellables = Set<AnyCancellable>()

    init(aiService: any AIService = MockAIService()) {
        self.aiService = aiService
        self.cameraService = CameraPostureService()
        self.motionService = MotionTrackingService()
        self.notificationService = NotificationService()
        self.sittingTracker = SittingTrackerService()

        forwardChanges(from: cameraService)
        forwardChanges(from: motionService)
        forwardChanges(from: notificationService)
        forwardChanges(from: sittingTracker)
    }

    private func forwardChanges<Object: ObservableObject>(from object: Object) where Object.ObjectWillChangePublisher == ObservableObjectPublisher {
        object.objectWillChange
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
}
