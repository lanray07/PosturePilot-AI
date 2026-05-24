import Foundation
import SwiftData
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appServices: AppServices
    @Query(sort: \PostureSession.createdAt, order: .reverse) private var postureSessions: [PostureSession]
    @Query(sort: \FocusSession.createdAt, order: .reverse) private var focusSessions: [FocusSession]
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                HStack(alignment: .center, spacing: 18) {
                    PostureScoreRing(score: viewModel.postureScore)
                    VStack(spacing: 12) {
                        metricTile("Streak", value: "\(viewModel.postureStreak)d", icon: "flame", tint: .ppAmber)
                        metricTile("Sitting", value: sittingText, icon: "chair", tint: .ppCyan)
                    }
                }

                ReminderCard(
                    title: "Next movement reset",
                    subtitle: viewModel.breakReminders == 0 ? "No breaks logged today" : "\(viewModel.breakReminders) breaks logged today",
                    icon: "figure.walk",
                    actionTitle: "Log"
                ) {
                    appServices.sittingTracker.recordMovementBreak()
                    refresh()
                }

                quickActions

                InsightChartCard(
                    title: "Posture trend",
                    subtitle: "Weekly score pattern",
                    samples: viewModel.trendSamples,
                    tint: .ppCyan
                )

                UpgradeBanner()
                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Today")
        .navigationDestination(for: AppRoute.self) { route in
            route.destination
        }
        .appBackground()
        .onAppear(perform: refresh)
        .onChange(of: postureSessions.count) { _, _ in refresh() }
        .onChange(of: focusSessions.count) { _, _ in refresh() }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in refresh() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PillLabel(title: "Mock AI enabled", icon: "cpu")
            Text("Steady posture habits, smarter breaks, calmer focus.")
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick actions")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                actionLink("Start Focus", icon: "timer", route: .focus, tint: .ppBlue)
                actionLink("Camera Check", icon: "camera.viewfinder", route: .cameraCheck, tint: .ppCyan)
                actionLink("Stretch Routine", icon: "figure.cooldown", route: .stretches, tint: .ppTeal)
                actionLink("Desk Scan", icon: "rectangle.and.text.magnifyingglass", route: .deskScanner, tint: .ppAmber)
                actionLink("View Insights", icon: "chart.xyaxis.line", route: .insights, tint: .ppCyan)
            }
        }
    }

    private var sittingText: String {
        let minutes = Int(viewModel.sittingTime / 60)
        if minutes < 60 { return "\(minutes)m" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }

    private func refresh() {
        viewModel.refresh(
            postureSessions: postureSessions,
            focusSessions: focusSessions,
            sittingDuration: appServices.sittingTracker.currentSittingDuration,
            breakCount: appServices.sittingTracker.breakCountToday
        )
    }

    private func metricTile(_ title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private func actionLink(_ title: String, icon: String, route: AppRoute, tint: Color) -> some View {
        NavigationLink(value: route) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(.primary)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
