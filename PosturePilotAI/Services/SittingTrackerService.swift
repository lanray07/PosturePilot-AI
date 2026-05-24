import Foundation

@MainActor
final class SittingTrackerService: ObservableObject {
    @Published private(set) var sittingStart: Date?
    @Published private(set) var currentSittingDuration: TimeInterval = 0
    @Published private(set) var breakCountToday = 0
    @Published private(set) var hydrationReminderEnabled = true

    private var timer: Timer?

    func startSittingSession() {
        sittingStart = Date()
        currentSittingDuration = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let sittingStart = self.sittingStart else { return }
                self.currentSittingDuration = Date().timeIntervalSince(sittingStart)
            }
        }
    }

    func recordMovementBreak() {
        breakCountToday += 1
        startSittingSession()
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
        sittingStart = nil
        currentSittingDuration = 0
    }

    func setHydrationReminderEnabled(_ enabled: Bool) {
        hydrationReminderEnabled = enabled
    }

    deinit {
        timer?.invalidate()
    }
}
