import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var lastScheduledReminder: Date?

    init() {
        Task { await refreshAuthorizationStatus() }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    func scheduleBreakReminder(afterMinutes minutes: Int, title: String = "PosturePilot reset") async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "Consider a short stand, stretch, or eye-rest break. \(WellnessDisclaimer.short)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(1, minutes) * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "posturepilot.break.\(UUID().uuidString)", content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
        lastScheduledReminder = Date().addingTimeInterval(TimeInterval(max(1, minutes) * 60))
    }

    func scheduleFocusSessionReminders(mode: FocusMode, durationMinutes: Int) async {
        await scheduleBreakReminder(afterMinutes: max(10, durationMinutes / 2), title: "\(mode.title) posture check")
        await scheduleBreakReminder(afterMinutes: max(15, durationMinutes), title: "\(mode.title) recovery prompt")
    }

    func removePendingPostureReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix("posturepilot.") }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        }
        lastScheduledReminder = nil
    }
}
