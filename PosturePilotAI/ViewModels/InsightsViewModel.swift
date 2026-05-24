import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published var weeklyTrend: [TrendSample] = []
    @Published var bestPostureStreak = 0
    @Published var sittingHours = 0.0
    @Published var breakConsistency = 0
    @Published var focusHistory: [TrendSample] = []
    @Published var improvementScore = 0
    @Published var insights: [PostureInsight] = []

    func refresh(
        postureSessions: [PostureSession],
        focusSessions: [FocusSession],
        routines: [StretchRoutine],
        aiService: any AIService
    ) async {
        weeklyTrend = makePostureTrend(from: postureSessions)
        bestPostureStreak = calculateBestStreak(from: postureSessions)
        sittingHours = postureSessions.map(\.sittingDuration).reduce(0, +) / 3_600
        breakConsistency = min(100, routines.filter(\.completed).count * 12)
        focusHistory = makeFocusHistory(from: focusSessions)
        improvementScore = calculateImprovementScore(from: postureSessions, routines: routines, focusSessions: focusSessions)
        insights = (try? await aiService.generatePostureInsights(from: postureSessions)) ?? []
    }

    private func makePostureTrend(from sessions: [PostureSession]) -> [TrendSample] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -6 + offset, to: Date()) else { return nil }
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? day
            let daily = sessions.filter { $0.createdAt >= start && $0.createdAt < end }
            let average = daily.isEmpty ? 70 + offset : daily.map(\.postureScore).reduce(0, +) / daily.count
            return TrendSample(label: formatter.string(from: day), value: average)
        }
    }

    private func makeFocusHistory(from sessions: [FocusSession]) -> [TrendSample] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -6 + offset, to: Date()) else { return nil }
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? day
            let dailyMinutes = sessions
                .filter { $0.createdAt >= start && $0.createdAt < end }
                .map(\.duration)
                .reduce(0, +) / 60
            return TrendSample(label: formatter.string(from: day), value: Int(dailyMinutes))
        }
    }

    private func calculateBestStreak(from sessions: [PostureSession]) -> Int {
        let sortedDays = Set(sessions.filter { $0.postureScore >= 75 }.map { Calendar.current.startOfDay(for: $0.createdAt) })
            .sorted()

        var best = 0
        var current = 0
        var previous: Date?

        for day in sortedDays {
            if let previous,
               Calendar.current.dateComponents([.day], from: previous, to: day).day == 1 {
                current += 1
            } else {
                current = 1
            }
            best = max(best, current)
            previous = day
        }

        return best
    }

    private func calculateImprovementScore(
        from sessions: [PostureSession],
        routines: [StretchRoutine],
        focusSessions: [FocusSession]
    ) -> Int {
        let postureAverage = sessions.isEmpty ? 74 : sessions.map(\.postureScore).reduce(0, +) / sessions.count
        let routineBoost = min(12, routines.filter(\.completed).count * 2)
        let focusBoost = min(10, focusSessions.filter(\.completed).count * 2)
        return min(100, postureAverage + routineBoost + focusBoost)
    }
}
