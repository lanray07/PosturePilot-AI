import SwiftData
import SwiftUI
import StoreKit

struct FocusSessionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var appServices: AppServices
    @AppStorage("focusSessionCompletionCount") private var focusSessionCompletionCount = 0
    @Query(sort: \FocusSession.createdAt, order: .reverse) private var sessions: [FocusSession]
    @StateObject private var viewModel = FocusSessionViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                    ForEach(FocusMode.allCases) { mode in
                        FocusSessionCard(mode: mode, isSelected: viewModel.selectedMode == mode) {
                            viewModel.selectedMode = mode
                        }
                    }
                }

                sessionTimer
                sessionControls

                ShareInviteCard(context: .focus(mode: viewModel.selectedMode), tint: .ppBlue)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Session prompts")
                        .font(.headline)
                    promptRow("Posture checks", icon: "person.crop.rectangle.stack")
                    promptRow("Break reminders", icon: "bell")
                    promptRow("Stretch prompts", icon: "figure.cooldown")
                    promptRow("Eye-rest reminders", icon: "eye")
                }

                recentHistory
                UpgradeBanner()
                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Focus")
        .navigationDestination(for: AppRoute.self) { route in
            route.destination
        }
        .appBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PillLabel(title: "Posture-aware focus", icon: viewModel.selectedMode.icon)
            Text("Stay immersed without letting breaks disappear.")
                .font(.title2.bold())
            VisualAssetCard(
                assetName: "FocusFlowVisual",
                height: 190,
                title: "\(viewModel.selectedMode.title) mode",
                subtitle: "Posture checks, eye-rest cues, and recovery prompts."
            )
        }
    }

    private var sessionTimer: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.ppCyan, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.snappy, value: viewModel.progress)
                VStack(spacing: 6) {
                    Text(viewModel.remainingText)
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    Text("\(viewModel.postureAlerts) posture prompts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 210, height: 210)

            Stepper(value: $viewModel.durationMinutes, in: 10...120, step: 5) {
                Text("\(viewModel.durationMinutes) minute session")
                    .font(.headline)
            }
            .disabled(viewModel.isRunning)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var sessionControls: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    viewModel.start(notificationService: appServices.notificationService)
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ppCyan)
                .disabled(viewModel.isRunning)

                Button {
                    viewModel.pause()
                } label: {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.isRunning)
            }

            HStack {
                Button {
                    viewModel.saveCompletion(in: modelContext)
                    recordFocusCompletion()
                } label: {
                    Label("Complete", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    viewModel.reset()
                } label: {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if let message = viewModel.completedMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color.ppTeal)
            }
        }
    }

    private var recentHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent sessions")
                .font(.headline)

            if sessions.isEmpty {
                EmptyStateView(title: "No focus sessions yet", subtitle: "Start a work, study, gaming, or deep focus block.", icon: "timer")
            } else {
                ForEach(sessions.prefix(4)) { session in
                    HStack {
                        Label(session.mode.title, systemImage: session.mode.icon)
                        Spacer()
                        Text("\(Int(session.duration / 60)) min")
                            .foregroundStyle(.secondary)
                    }
                    .cardStyle()
                }
            }
        }
    }

    private func promptRow(_ title: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.ppTeal)
        }
        .font(.subheadline)
        .cardStyle()
    }

    private func recordFocusCompletion() {
        focusSessionCompletionCount += 1
        if GrowthService.shouldRequestReview(completionCount: focusSessionCompletionCount) {
            requestReview()
        }
    }
}
