import SwiftUI

struct SittingDetectionView: View {
    @EnvironmentObject private var appServices: AppServices

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Smart sitting detection")
                    .font(.title2.bold())
                Text("CoreMotion and timer placeholders track sitting duration, inactivity, movement frequency, and posture consistency locally.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    metricRow("Sitting duration", value: durationText, icon: "chair")
                    metricRow("Inactivity", value: "\(appServices.motionService.inactivityMinutes) min", icon: "pause.circle")
                    metricRow("Movement frequency", value: percent(appServices.motionService.movementFrequency), icon: "waveform.path.ecg")
                    metricRow("Posture consistency", value: percent(appServices.motionService.postureConsistency), icon: "scope")
                }

                ReminderCard(
                    title: "Stretch reminder",
                    subtitle: "Schedule a gentle movement prompt.",
                    icon: "figure.cooldown",
                    actionTitle: "Schedule"
                ) {
                    Task { await appServices.notificationService.scheduleBreakReminder(afterMinutes: 25) }
                }

                ReminderCard(
                    title: "Hydration placeholder",
                    subtitle: appServices.sittingTracker.hydrationReminderEnabled ? "Hydration prompts are enabled." : "Hydration prompts are paused.",
                    icon: "drop",
                    actionTitle: "Toggle"
                ) {
                    appServices.sittingTracker.setHydrationReminderEnabled(!appServices.sittingTracker.hydrationReminderEnabled)
                }

                HStack {
                    Button("Restart sitting timer") {
                        appServices.sittingTracker.startSittingSession()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.ppCyan)

                    Button("Log movement") {
                        appServices.sittingTracker.recordMovementBreak()
                    }
                    .buttonStyle(.bordered)
                }

                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Sitting")
        .appBackground()
    }

    private var durationText: String {
        let minutes = Int(appServices.sittingTracker.currentSittingDuration / 60)
        return minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h \(minutes % 60)m"
    }

    private func percent(_ value: Double) -> String {
        "\(Int(value * 100))%"
    }

    private func metricRow(_ title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundStyle(Color.ppCyan)
        }
        .cardStyle()
    }
}
