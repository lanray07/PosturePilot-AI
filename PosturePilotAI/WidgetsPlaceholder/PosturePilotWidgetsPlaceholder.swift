import Foundation

#if canImport(WidgetKit)
import WidgetKit

struct PosturePilotWidgetEntry: TimelineEntry {
    let date: Date
    let postureScore: Int
    let sittingMinutes: Int
    let nextBreakText: String
    let streak: Int
}

enum PosturePilotWidgetTimelineFactory {
    static func placeholderEntry() -> PosturePilotWidgetEntry {
        PosturePilotWidgetEntry(
            date: Date(),
            postureScore: 84,
            sittingMinutes: 42,
            nextBreakText: "18 min",
            streak: 3
        )
    }
}
#endif

struct WidgetPlaceholderConfiguration {
    var includesPostureScore = true
    var includesSittingTimer = true
    var includesNextBreakReminder = true
    var includesStreakCounter = true
}
