import Foundation
import SwiftData

@MainActor
final class FocusSessionViewModel: ObservableObject {
    @Published var selectedMode: FocusMode = .work {
        didSet {
            guard !isRunning else { return }
            durationMinutes = selectedMode.defaultMinutes
            remainingSeconds = selectedMode.defaultMinutes * 60
        }
    }
    @Published var durationMinutes = FocusMode.work.defaultMinutes
    @Published var remainingSeconds = FocusMode.work.defaultMinutes * 60
    @Published var postureAlerts = 0
    @Published var isRunning = false
    @Published var completedMessage: String?

    private var timer: Timer?

    var progress: Double {
        guard durationMinutes > 0 else { return 0 }
        let total = Double(durationMinutes * 60)
        return max(0, min(1, 1 - Double(remainingSeconds) / total))
    }

    var remainingText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start(notificationService: NotificationService) {
        guard !isRunning else { return }
        completedMessage = nil
        remainingSeconds = durationMinutes * 60
        postureAlerts = 0
        isRunning = true

        Task {
            await notificationService.scheduleFocusSessionReminders(mode: selectedMode, durationMinutes: durationMinutes)
        }

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isRunning else { return }
                self.remainingSeconds = max(0, self.remainingSeconds - 1)
                if self.remainingSeconds > 0, self.remainingSeconds % 600 == 0 {
                    self.postureAlerts += 1
                }
                if self.remainingSeconds == 0 {
                    self.isRunning = false
                    self.timer?.invalidate()
                    self.completedMessage = "Session ready to save. Nice steady effort."
                }
            }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
    }

    func reset() {
        isRunning = false
        timer?.invalidate()
        remainingSeconds = durationMinutes * 60
        postureAlerts = 0
        completedMessage = nil
    }

    func saveCompletion(in context: ModelContext, completed: Bool = true) {
        let session = FocusSession(
            mode: selectedMode,
            duration: TimeInterval(durationMinutes * 60 - remainingSeconds),
            postureAlerts: postureAlerts,
            completed: completed
        )
        context.insert(session)
        try? context.save()
        completedMessage = completed ? "Focus session saved." : "Focus session logged."
        reset()
    }

    deinit {
        timer?.invalidate()
    }
}
