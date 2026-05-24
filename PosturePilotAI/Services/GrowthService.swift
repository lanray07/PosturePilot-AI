import Foundation

enum GrowthShareContext {
    case general
    case dashboard(score: Int, streak: Int)
    case insights(improvementScore: Int)
    case achievement(String)
    case focus(mode: FocusMode)
    case stretch(String)

    var title: String {
        switch self {
        case .general:
            "Share PosturePilot AI"
        case .dashboard:
            "Share today's posture routine"
        case .insights:
            "Share your desk routine progress"
        case .achievement:
            "Share an achievement"
        case .focus:
            "Share your focus routine"
        case .stretch:
            "Share your reset"
        }
    }

    var subtitle: String {
        switch self {
        case .general:
            "Invite a desk-heavy friend to build better posture habits."
        case .dashboard:
            "Turn a good desk day into a small accountability nudge."
        case .insights:
            "Share a progress moment without exposing private session data."
        case .achievement:
            "Celebrate a healthy desk habit milestone."
        case .focus:
            "Invite someone into a calmer work rhythm."
        case .stretch:
            "Nudge someone to take a quick movement reset."
        }
    }

    var icon: String {
        switch self {
        case .general: "square.and.arrow.up"
        case .dashboard: "flame"
        case .insights: "chart.line.uptrend.xyaxis"
        case .achievement: "rosette"
        case .focus: "timer"
        case .stretch: "figure.cooldown"
        }
    }
}

enum GrowthService {
    static let appStoreURL = "https://apps.apple.com/app/id0000000000"

    static func shareText(for context: GrowthShareContext) -> String {
        let base = "PosturePilot AI helps desk-heavy people build posture checks, focus breaks, stretches, and ergonomic awareness into the day."

        switch context {
        case .general:
            return "\(base)\n\nTry it: \(appStoreURL)"
        case .dashboard(let score, let streak):
            return "My PosturePilot AI desk routine is at \(score)/100 today with a \(streak)-day posture streak. Small resets, better habits.\n\n\(appStoreURL)"
        case .insights(let improvementScore):
            return "My PosturePilot AI improvement score is \(improvementScore). Building a healthier desk routine one check at a time.\n\n\(appStoreURL)"
        case .achievement(let title):
            return "I unlocked '\(title)' in PosturePilot AI. Tiny desk-habit wins count.\n\n\(appStoreURL)"
        case .focus(let mode):
            return "I just used \(mode.title) mode in PosturePilot AI to pair focus with posture and break reminders.\n\n\(appStoreURL)"
        case .stretch(let title):
            return "I took a quick \(title) reset with PosturePilot AI. Your turn to move for a minute?\n\n\(appStoreURL)"
        }
    }

    static func shouldRequestReview(completionCount: Int) -> Bool {
        completionCount == 2 || completionCount == 5 || completionCount == 10
    }
}
