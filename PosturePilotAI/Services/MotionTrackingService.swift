import CoreMotion
import Foundation

@MainActor
final class MotionTrackingService: ObservableObject {
    @Published private(set) var isAvailable: Bool
    @Published private(set) var isMonitoring = false
    @Published private(set) var inactivityMinutes = 0
    @Published private(set) var movementFrequency = 0.62
    @Published private(set) var postureConsistency = 0.76

    private let activityManager = CMMotionActivityManager()
    private var inactivityTimer: Timer?

    init() {
        isAvailable = CMMotionActivityManager.isActivityAvailable()
    }

    func requestPlaceholderAccess() async -> Bool {
        guard isAvailable else { return false }
        startMonitoring()
        try? await Task.sleep(nanoseconds: 600_000_000)
        return true
    }

    func startMonitoring() {
        guard isAvailable, !isMonitoring else { return }
        isMonitoring = true

        activityManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self else { return }
            Task { @MainActor in
                if activity?.walking == true || activity?.running == true {
                    self.inactivityMinutes = 0
                    self.movementFrequency = min(1.0, self.movementFrequency + 0.05)
                    self.postureConsistency = min(1.0, self.postureConsistency + 0.02)
                }
            }
        }

        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isMonitoring else { return }
                self.inactivityMinutes += 1
                self.movementFrequency = max(0.1, self.movementFrequency - 0.02)
                self.postureConsistency = max(0.2, self.postureConsistency - 0.01)
            }
        }
    }

    func stopMonitoring() {
        activityManager.stopActivityUpdates()
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        isMonitoring = false
    }

    deinit {
        activityManager.stopActivityUpdates()
        inactivityTimer?.invalidate()
    }
}
