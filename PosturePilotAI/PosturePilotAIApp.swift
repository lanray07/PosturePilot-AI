import SwiftData
import SwiftUI

@main
struct PosturePilotAIApp: App {
    @StateObject private var appServices = AppServices()
    @AppStorage("appearance") private var appearance = "dark"

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appServices)
                .preferredColorScheme(colorScheme)
                .tint(.ppCyan)
        }
        .modelContainer(for: [
            UserProfile.self,
            PostureSession.self,
            FocusSession.self,
            StretchRoutine.self,
            DeskSetupScan.self,
            Achievement.self,
            SubscriptionState.self
        ])
    }

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light": .light
        case "system": nil
        default: .dark
        }
    }
}
