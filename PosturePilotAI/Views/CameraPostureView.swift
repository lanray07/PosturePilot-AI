import SwiftData
import SwiftUI

struct CameraPostureView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appServices: AppServices
    @StateObject private var viewModel = CameraPostureViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                cameraPreview

                Button {
                    Task {
                        await viewModel.runCheck(
                            cameraService: appServices.cameraService,
                            sittingTracker: appServices.sittingTracker,
                            aiService: appServices.aiService,
                            context: modelContext
                        )
                    }
                } label: {
                    Label(viewModel.isWorking ? "Analyzing" : "Run Posture Check", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ppCyan)
                .disabled(viewModel.isWorking)

                phaseView

                if let result = viewModel.result {
                    resultView(result)
                }

                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Camera Check")
        .appBackground()
    }

    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.ppSurfaceRaised)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ppCyan.opacity(0.18), lineWidth: 1)
                )

            VStack(spacing: 14) {
                Image(systemName: "person.crop.rectangle.stack")
                    .font(.system(size: 62))
                    .foregroundStyle(Color.ppCyan)
                Text("Front camera posture detection placeholder")
                    .font(.headline)
                Text("Production builds can replace this preview with an AVCaptureSession and on-device vision pipeline.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(height: 320)
    }

    @ViewBuilder
    private var phaseView: some View {
        switch viewModel.phase {
        case .idle:
            EmptyStateView(title: "Ready for a check", subtitle: "Run a camera posture check to create a local session.", icon: "sparkles")
        case .requestingPermission:
            LoadingStateView(title: "Checking camera permission")
        case .analyzing:
            LoadingStateView(title: "Mock AI is reviewing posture cues")
        case .complete:
            EmptyView()
        case .failed(let message):
            ErrorStateView(title: "Posture check unavailable", message: message)
        }
    }

    private func resultView(_ result: PostureAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                PostureScoreRing(score: result.postureScore, size: 118, lineWidth: 12)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Posture summary")
                        .font(.headline)
                    Text(result.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Label(result.suggestedCorrection, systemImage: "figure.stand")
                .font(.subheadline)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Desk setup tips")
                    .font(.headline)
                ForEach(result.deskSetupTips, id: \.self) { tip in
                    Label(tip, systemImage: "display")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Label(result.movementReminder, systemImage: "figure.walk")
                .font(.subheadline)
                .foregroundStyle(Color.ppTeal)
        }
        .cardStyle()
    }
}
