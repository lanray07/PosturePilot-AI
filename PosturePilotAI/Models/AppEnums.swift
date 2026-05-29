import Foundation

enum WorkStyle: String, CaseIterable, Identifiable, Codable {
    case office
    case remote
    case student
    case gamer
    case creator

    var id: String { rawValue }

    var title: String {
        switch self {
        case .office: "Office"
        case .remote: "Remote"
        case .student: "Student"
        case .gamer: "Gamer"
        case .creator: "Creator"
        }
    }

    var icon: String {
        switch self {
        case .office: "building.2"
        case .remote: "house.lodge"
        case .student: "graduationcap"
        case .gamer: "gamecontroller"
        case .creator: "paintpalette"
        }
    }
}

enum PostureGoal: String, CaseIterable, Identifiable, Codable {
    case reduceSlouching
    case reduceNeckStrain
    case improveSittingPosture
    case standMoreOften
    case improveErgonomics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .reduceSlouching: "Reduce slouching"
        case .reduceNeckStrain: "Reduce neck strain posture"
        case .improveSittingPosture: "Improve sitting posture"
        case .standMoreOften: "Stand more often"
        case .improveErgonomics: "Improve ergonomics"
        }
    }

    var icon: String {
        switch self {
        case .reduceSlouching: "figure.stand"
        case .reduceNeckStrain: "person.crop.circle.badge.exclamationmark"
        case .improveSittingPosture: "chair"
        case .standMoreOften: "figure.walk"
        case .improveErgonomics: "display"
        }
    }
}

enum FocusMode: String, CaseIterable, Identifiable, Codable {
    case work
    case study
    case gaming
    case deepFocus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: "Work"
        case .study: "Study"
        case .gaming: "Gaming"
        case .deepFocus: "Deep Focus"
        }
    }

    var icon: String {
        switch self {
        case .work: "briefcase"
        case .study: "book"
        case .gaming: "gamecontroller"
        case .deepFocus: "moon.stars"
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .work: 25
        case .study: 35
        case .gaming: 45
        case .deepFocus: 60
        }
    }
}

enum StretchCategory: String, CaseIterable, Identifiable, Codable {
    case neckStretch
    case shoulderReset
    case upperBackMobility
    case wristStretch
    case standingReset
    case deskDecompression

    var id: String { rawValue }

    var title: String {
        switch self {
        case .neckStretch: "Neck stretch"
        case .shoulderReset: "Shoulder reset"
        case .upperBackMobility: "Upper back mobility"
        case .wristStretch: "Wrist stretch"
        case .standingReset: "Standing reset"
        case .deskDecompression: "Desk decompression"
        }
    }

    var icon: String {
        switch self {
        case .neckStretch: "person.crop.circle"
        case .shoulderReset: "figure.arms.open"
        case .upperBackMobility: "figure.flexibility"
        case .wristStretch: "hand.raised"
        case .standingReset: "figure.stand"
        case .deskDecompression: "chair.lounge"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case proMonthly
    case proYearly
    case eliteMonthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro Monthly"
        case .proYearly: "Pro Yearly"
        case .eliteMonthly: "Elite Monthly"
        }
    }

    var price: String {
        switch self {
        case .free: "£0"
        case .proMonthly: "£7.99"
        case .proYearly: "£59.99"
        case .eliteMonthly: "£14.99"
        }
    }

    var productID: String? {
        switch self {
        case .free: nil
        case .proMonthly: "com.posturepilotai.pro.monthly"
        case .proYearly: "com.posturepilotai.pro.yearly"
        case .eliteMonthly: "com.posturepilotai.elite.monthly"
        }
    }

    var duration: String {
        switch self {
        case .free: "No subscription"
        case .proMonthly, .eliteMonthly: "1 month, auto-renewing"
        case .proYearly: "1 year, auto-renewing"
        }
    }

    var includedFeatures: [String] {
        switch self {
        case .free:
            [
                "Basic posture tracking",
                "Limited reminders",
                "7-day history"
            ]
        case .proMonthly, .proYearly:
            [
                "AI posture analysis",
                "Unlimited focus sessions",
                "Advanced insights",
                "Ergonomics scanner",
                "Apple Watch placeholders",
                "Widgets placeholders",
                "Premium routines"
            ]
        case .eliteMonthly:
            [
                "Advanced AI analysis",
                "Custom reminder modes",
                "Detailed posture reports",
                "Productivity insights",
                "Premium themes"
            ]
        }
    }
}

enum LegalLinks {
    static let support = URL(string: "https://lanray07.github.io/PosturePilot-AI/support/")!
    static let privacy = URL(string: "https://lanray07.github.io/PosturePilot-AI/privacy/")!
    static let terms = URL(string: "https://lanray07.github.io/PosturePilot-AI/terms/")!
}

enum ReminderSensitivity: String, CaseIterable, Identifiable, Codable {
    case gentle
    case balanced
    case active

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle: "Gentle"
        case .balanced: "Balanced"
        case .active: "Active"
        }
    }

    var intervalMinutes: Int {
        switch self {
        case .gentle: 60
        case .balanced: 40
        case .active: 25
        }
    }
}

enum WellnessDisclaimer {
    static let short = "PosturePilot AI is not a medical device. Insights are informational only and are not medical advice."

    static let statements = [
        "Not medical advice",
        "Not a medical device",
        "AI posture insights are informational only",
        "Seek professional care for pain or injuries"
    ]

    static let aiPrompt = """
    You are PosturePilot AI, a wellness-focused posture and ergonomics assistant. Help users improve posture habits, movement frequency, and desk ergonomics using supportive, non-medical language. Do not diagnose medical conditions, injuries, spinal disorders, or chronic pain. Recommend professional medical advice where appropriate.
    """
}
