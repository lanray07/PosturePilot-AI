import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var postureScore = 82
    @Published var postureStreak = 0
    @Published var sittingTime: TimeInterval = 0
    @Published var postureAlerts = 0
    @Published var breakReminders = 0
    @Published var focusMinutesToday = 0
    @Published var trendSamples: [TrendSample] = []

    func refresh(
        postureSessions: [PostureSession],
        focusSessions: [FocusSession],
        sittingDuration: TimeInterval,
        breakCount: Int
    ) {
        sittingTime = sittingDuration
        breakReminders = breakCount

        let today = Calendar.current.startOfDay(for: Date())
        let todaysPosture = postureSessions.filter { $0.createdAt >= today }
        let todaysFocus = focusSessions.filter { $0.createdAt >= today }

        postureScore = todaysPosture.first?.postureScore ?? postureSessions.first?.postureScore ?? 82
        postureAlerts = todaysPosture.filter {
            $0.slouchDetected || $0.headTiltDetected || $0.shoulderImbalanceDetected || $0.leaningDetected || $0.downwardGazeDetected
        }.count
        postureStreak = calculateStreak(from: postureSessions)
        focusMinutesToday = Int(todaysFocus.map(\.duration).reduce(0, +) / 60)
        trendSamples = makeTrendSamples(from: postureSessions)
    }

    private func calculateStreak(from sessions: [PostureSession]) -> Int {
        let groupedByDay = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.createdAt)
        }

        var streak = 0
        var day = Calendar.current.startOfDay(for: Date())

        while groupedByDay[day]?.contains(where: { $0.postureScore >= 75 }) == true {
            streak += 1
            guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }

    private func makeTrendSamples(from sessions: [PostureSession]) -> [TrendSample] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -6 + offset, to: Date()) else { return nil }
            let start = calendar.startOfDay(for: day)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? day
            let daily = sessions.filter { $0.createdAt >= start && $0.createdAt < end }
            let average = daily.isEmpty ? nil : daily.map(\.postureScore).reduce(0, +) / daily.count
            return TrendSample(label: formatter.string(from: day), value: average ?? 72 + offset)
        }
    }
}
