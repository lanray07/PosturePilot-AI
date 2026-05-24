import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appServices: AppServices
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var step = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    switch step {
                    case 0:
                        workStyleStep
                    case 1:
                        sittingHoursStep
                    case 2:
                        goalStep
                    case 3:
                        permissionsStep
                    default:
                        disclaimerStep
                    }

                    HStack {
                        if step > 0 {
                            Button {
                                withAnimation(.snappy) { step -= 1 }
                            } label: {
                                Label("Back", systemImage: "chevron.left")
                            }
                            .buttonStyle(.bordered)
                        }

                        Spacer()

                        Button {
                            advance()
                        } label: {
                            Label(step == 4 ? "Start" : "Next", systemImage: step == 4 ? "checkmark" : "chevron.right")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.ppCyan)
                    }
                }
                .padding(20)
            }
            .navigationTitle("PosturePilot AI")
            .appBackground()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            VisualAssetCard(
                assetName: "HeroPosture",
                height: 244,
                title: "PosturePilot AI",
                subtitle: "Camera checks, calmer focus, and ergonomic awareness."
            )
            PillLabel(title: "Wellness-tech posture habits", icon: "sparkles")
            Text("Build healthier desk routines with posture checks, movement breaks, focus sessions, and ergonomic awareness.")
                .font(.title2.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text(WellnessDisclaimer.short)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var workStyleStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What best describes your desk life?")
                .font(.title3.bold())

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 136), spacing: 12)], spacing: 12) {
                ForEach(WorkStyle.allCases) { style in
                    Button {
                        viewModel.selectedWorkStyle = style
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: style.icon)
                                .font(.title2)
                                .foregroundStyle(viewModel.selectedWorkStyle == style ? Color.ppCyan : Color.secondary)
                            Text(style.title)
                                .font(.headline)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
                        .cardStyle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.selectedWorkStyle == style ? Color.ppCyan : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sittingHoursStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Average sitting hours")
                .font(.title3.bold())
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .lastTextBaseline) {
                    Text(viewModel.averageSittingHours, format: .number.precision(.fractionLength(1)))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("hours/day")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $viewModel.averageSittingHours, in: 1...14, step: 0.5)
                    .tint(.ppCyan)
                Text("This helps tune reminder frequency and posture check timing.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .cardStyle()
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose your main goal")
                .font(.title3.bold())
            ForEach(PostureGoal.allCases) { goal in
                Button {
                    viewModel.selectedGoal = goal
                } label: {
                    HStack {
                        Label(goal.title, systemImage: goal.icon)
                        Spacer()
                        Image(systemName: viewModel.selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedGoal == goal ? Color.ppCyan : Color.secondary)
                    }
                    .foregroundStyle(.primary)
                    .cardStyle()
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var permissionsStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Set reminder and sensor preferences")
                .font(.title3.bold())

            Toggle(isOn: $viewModel.notificationsEnabled) {
                Label("Posture and movement reminders", systemImage: "bell")
            }
            .cardStyle()

            Button {
                Task { await viewModel.requestNotificationPermission(using: appServices.notificationService) }
            } label: {
                Label("Allow Notifications", systemImage: "bell.badge")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.ppBlue)

            Button {
                Task { await viewModel.requestCameraPermission(using: appServices.cameraService) }
            } label: {
                Label(viewModel.cameraPermissionRequested ? "Camera Requested" : "Request Camera Permission", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                Task { await viewModel.requestMotionPermission(using: appServices.motionService) }
            } label: {
                Label(viewModel.motionPermissionRequested ? "Motion Requested" : "Request Motion Access", systemImage: "waveform.path.ecg")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var disclaimerStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Before you start")
                .font(.title3.bold())
            WellnessDisclaimerView()
        }
    }

    private func advance() {
        if step < 4 {
            withAnimation(.snappy) { step += 1 }
        } else if viewModel.complete(in: modelContext) {
            hasCompletedOnboarding = true
        }
    }
}
