import SwiftUI

enum AppRoute: Hashable {
    case cameraCheck
    case sittingDetection
    case focus
    case stretches
    case deskScanner
    case insights
    case achievements
    case paywall
}

extension AppRoute {
    @ViewBuilder
    var destination: some View {
        switch self {
        case .cameraCheck:
            CameraPostureView()
        case .sittingDetection:
            SittingDetectionView()
        case .focus:
            FocusSessionsView()
        case .stretches:
            StretchRoutinesView()
        case .deskScanner:
            DeskScannerView()
        case .insights:
            InsightsView()
        case .achievements:
            AchievementsView()
        case .paywall:
            PaywallView()
        }
    }
}
