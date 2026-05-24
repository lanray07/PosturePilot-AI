import Foundation

struct WatchReminderPayload: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var body: String
    var vibrationEnabled: Bool
    var createdAt: Date
}

protocol WatchReminderProviding {
    func makeStandAlert(after minutes: Int) -> WatchReminderPayload
    func makeQuickStretchPrompt(category: StretchCategory) -> WatchReminderPayload
}

struct WatchPlaceholderService: WatchReminderProviding {
    func makeStandAlert(after minutes: Int) -> WatchReminderPayload {
        WatchReminderPayload(
            title: "Stand alert",
            body: "Consider standing or moving in \(minutes) minutes.",
            vibrationEnabled: true,
            createdAt: Date()
        )
    }

    func makeQuickStretchPrompt(category: StretchCategory) -> WatchReminderPayload {
        WatchReminderPayload(
            title: "Quick stretch",
            body: "Try a short \(category.title.lowercased()) reset.",
            vibrationEnabled: true,
            createdAt: Date()
        )
    }
}

#if canImport(WatchConnectivity)
import WatchConnectivity

final class WatchConnectivityPlaceholder: NSObject, WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
#endif
