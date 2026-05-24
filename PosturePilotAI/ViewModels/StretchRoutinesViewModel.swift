import Foundation
import SwiftData

@MainActor
final class StretchRoutinesViewModel: ObservableObject {
    @Published var selectedCategory: StretchCategory?
    @Published var activeRoutine: StretchRoutine?
    @Published var remainingSeconds = 0
    @Published var isTimerRunning = false
    @Published var recommendations: [StretchRecommendation] = []
    @Published var errorMessage: String?

    private var timer: Timer?

    func loadRecommendations(aiService: any AIService) async {
        do {
            recommendations = try await aiService.generateStretchRecommendations(for: selectedCategory)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func start(_ routine: StretchRoutine) {
        activeRoutine = routine
        remainingSeconds = Int(routine.duration)
        isTimerRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.isTimerRunning else { return }
                self.remainingSeconds = max(0, self.remainingSeconds - 1)
                if self.remainingSeconds == 0 {
                    self.isTimerRunning = false
                    self.timer?.invalidate()
                }
            }
        }
    }

    func completeActiveRoutine(in context: ModelContext) {
        guard let activeRoutine else { return }
        activeRoutine.completed = true
        try? context.save()
        self.activeRoutine = nil
        isTimerRunning = false
        timer?.invalidate()
    }

    func cancel() {
        activeRoutine = nil
        isTimerRunning = false
        timer?.invalidate()
    }

    deinit {
        timer?.invalidate()
    }
}
