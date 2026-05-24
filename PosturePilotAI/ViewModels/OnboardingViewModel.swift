import Foundation
import SwiftData

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var selectedWorkStyle: WorkStyle = .remote
    @Published var averageSittingHours = 7.0
    @Published var selectedGoal: PostureGoal = .improveSittingPosture
    @Published var notificationsEnabled = true
    @Published var cameraPermissionRequested = false
    @Published var motionPermissionRequested = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    func requestNotificationPermission(using service: NotificationService) async {
        notificationsEnabled = await service.requestAuthorization()
    }

    func requestCameraPermission(using service: CameraPostureService) async {
        cameraPermissionRequested = true
        _ = await service.requestPermission()
    }

    func requestMotionPermission(using service: MotionTrackingService) async {
        motionPermissionRequested = true
        _ = await service.requestPlaceholderAccess()
    }

    func complete(in context: ModelContext) -> Bool {
        isSaving = true
        defer { isSaving = false }

        let profile = UserProfile(
            workStyle: selectedWorkStyle,
            sittingHours: averageSittingHours,
            postureGoal: selectedGoal,
            notificationsEnabled: notificationsEnabled,
            cameraPermissionRequested: cameraPermissionRequested,
            motionPermissionRequested: motionPermissionRequested
        )

        context.insert(profile)

        do {
            try context.save()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
