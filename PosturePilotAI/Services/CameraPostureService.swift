import AVFoundation
import Foundation

@MainActor
final class CameraPostureService: ObservableObject {
    enum CameraState: Equatable {
        case idle
        case permissionNeeded
        case ready
        case running
        case unavailable(String)
    }

    @Published private(set) var authorizationStatus: AVAuthorizationStatus
    @Published private(set) var state: CameraState = .idle

    init() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        state = authorizationStatus == .authorized ? .ready : .permissionNeeded
    }

    func requestPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationStatus = .authorized
            state = .ready
            return true
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }
            authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            state = granted ? .ready : .permissionNeeded
            return granted
        case .denied, .restricted:
            authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            state = .permissionNeeded
            return false
        @unknown default:
            state = .unavailable("Camera authorization is unavailable on this device.")
            return false
        }
    }

    func startPlaceholderCamera() {
        state = .running
    }

    func stopPlaceholderCamera() {
        state = authorizationStatus == .authorized ? .ready : .permissionNeeded
    }

    func capturePlaceholderMetrics() -> PostureSignal {
        let minute = Calendar.current.component(.minute, from: Date())
        let pulse = Double(minute % 9) / 30.0
        return PostureSignal(
            slouchConfidence: min(0.64, 0.24 + pulse),
            headTiltConfidence: min(0.55, 0.18 + pulse / 1.4),
            shoulderImbalanceConfidence: min(0.50, 0.20 + pulse / 1.8),
            leaningConfidence: min(0.45, 0.16 + pulse / 2.0),
            downwardGazeConfidence: min(0.58, 0.22 + pulse / 1.5)
        )
    }
}
