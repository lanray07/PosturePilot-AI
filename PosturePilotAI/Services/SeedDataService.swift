import Foundation
import SwiftData

enum SeedDataService {
    @MainActor
    static func seedDefaultsIfNeeded(in context: ModelContext) {
        let achievements = (try? context.fetch(FetchDescriptor<Achievement>())) ?? []
        if achievements.isEmpty {
            defaultAchievements.forEach { context.insert($0) }
        }

        let routines = (try? context.fetch(FetchDescriptor<StretchRoutine>())) ?? []
        if routines.isEmpty {
            defaultStretchRoutines.forEach { context.insert($0) }
        }

        try? context.save()
    }

    private static var defaultAchievements: [Achievement] {
        [
            Achievement(title: "First Session", description: "Complete your first posture or focus session.", icon: "sparkles", unlocked: true, unlockedAt: Date()),
            Achievement(title: "Perfect Posture Day", description: "Keep all posture checks above 90 for a day.", icon: "seal"),
            Achievement(title: "7-Day Streak", description: "Return to PosturePilot for seven days.", icon: "flame"),
            Achievement(title: "Deep Focus Master", description: "Complete three deep focus sessions.", icon: "moon.stars"),
            Achievement(title: "Movement Champion", description: "Complete five stretch or movement resets.", icon: "figure.walk"),
            Achievement(title: "Ergonomic Upgrade", description: "Run a desk setup scan and apply a workspace improvement.", icon: "display")
        ]
    }

    private static var defaultStretchRoutines: [StretchRoutine] {
        [
            StretchRoutine(title: "Neck Glide", category: .neckStretch, duration: 60),
            StretchRoutine(title: "Shoulder Reset", category: .shoulderReset, duration: 75),
            StretchRoutine(title: "Upper Back Opener", category: .upperBackMobility, duration: 90),
            StretchRoutine(title: "Wrist Flow", category: .wristStretch, duration: 60),
            StretchRoutine(title: "Standing Reset", category: .standingReset, duration: 120),
            StretchRoutine(title: "Desk Decompression", category: .deskDecompression, duration: 150)
        ]
    }
}
