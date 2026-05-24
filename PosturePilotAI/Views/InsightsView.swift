import SwiftData
import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var appServices: AppServices
    @Query(sort: \PostureSession.createdAt, order: .reverse) private var postureSessions: [PostureSession]
    @Query(sort: \FocusSession.createdAt, order: .reverse) private var focusSessions: [FocusSession]
    @Query(sort: \StretchRoutine.createdAt, order: .reverse) private var routines: [StretchRoutine]
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    statTile("Best streak", value: "\(viewModel.bestPostureStreak)d", icon: "flame", tint: .ppAmber)
                    statTile("Sitting hours", value: viewModel.sittingHours.formatted(.number.precision(.fractionLength(1))), icon: "chair", tint: .ppCyan)
                    statTile("Break consistency", value: "\(viewModel.breakConsistency)%", icon: "figure.walk", tint: .ppTeal)
                    statTile("Improvement", value: "\(viewModel.improvementScore)", icon: "arrow.up.forward", tint: .ppBlue)
                }

                InsightChartCard(
                    title: "Weekly posture trend",
                    subtitle: "Average score by day",
                    samples: viewModel.weeklyTrend,
                    tint: .ppCyan
                )

                InsightChartCard(
                    title: "Focus history",
                    subtitle: "Minutes completed by day",
                    samples: viewModel.focusHistory,
                    tint: .ppTeal
                )

                aiInsights

                NavigationLink(value: AppRoute.achievements) {
                    HStack {
                        Label("Achievements", systemImage: "rosette")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.primary)
                    .cardStyle()
                }
                .buttonStyle(.plain)

                UpgradeBanner()
                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Insights")
        .navigationDestination(for: AppRoute.self) { route in
            route.destination
        }
        .appBackground()
        .task(id: postureSessions.count + focusSessions.count + routines.count) {
            await viewModel.refresh(
                postureSessions: postureSessions,
                focusSessions: focusSessions,
                routines: routines,
                aiService: appServices.aiService
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PillLabel(title: "Analytics", icon: "chart.line.uptrend.xyaxis")
            Text("See posture patterns, focus history, breaks, and progress signals.")
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var aiInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI posture insights")
                .font(.headline)

            if viewModel.insights.isEmpty {
                EmptyStateView(title: "No insights yet", subtitle: "Complete posture checks to generate weekly insights.", icon: "sparkles")
            } else {
                ForEach(viewModel.insights) { insight in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(insight.title)
                                .font(.headline)
                            Spacer()
                            Text(insight.scoreDelta >= 0 ? "+\(insight.scoreDelta)" : "\(insight.scoreDelta)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(insight.scoreDelta >= 0 ? Color.ppTeal : Color.ppAmber)
                        }
                        Text(insight.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }
            }
        }
    }

    private func statTile(_ title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
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
}
