import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appServices: AppServices
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                AppShellView()
            } else {
                OnboardingView()
            }
        }
        .task {
            appServices.sittingTracker.startSittingSession()
            appServices.motionService.startMonitoring()
        }
    }
}
