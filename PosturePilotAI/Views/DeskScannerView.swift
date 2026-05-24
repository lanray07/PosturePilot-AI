import SwiftData
import SwiftUI

struct DeskScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appServices: AppServices
    @StateObject private var viewModel = DeskScannerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                cameraPlaceholder

                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Monitor near eye level", isOn: $viewModel.monitorNearEyeLevel)
                    Toggle("Feet supported", isOn: $viewModel.feetSupported)
                    Toggle("Keyboard and mouse close", isOn: $viewModel.keyboardClose)
                    Toggle("Soft lighting", isOn: $viewModel.softLighting)
                }
                .cardStyle()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Workspace notes")
                        .font(.headline)
                    TextField("Laptop stand, second monitor, chair height...", text: $viewModel.workspaceNotes, axis: .vertical)
                        .lineLimit(4...8)
                        .textFieldStyle(.roundedBorder)
                }
                .cardStyle()

                Button {
                    Task {
                        await viewModel.generateScan(aiService: appServices.aiService, context: modelContext)
                    }
                } label: {
                    Label(viewModel.isScanning ? "Generating" : "Generate Ergonomic Suggestions", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ppCyan)
                .disabled(viewModel.isScanning)

                if viewModel.isScanning {
                    LoadingStateView(title: "Reviewing workspace setup")
                }

                if let result = viewModel.result {
                    DeskSetupCard(score: result.setupScore, recommendations: result.recommendations)
                }

                if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(title: "Scanner unavailable", message: errorMessage)
                }

                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Desk Scan")
        .appBackground()
    }

    private var cameraPlaceholder: some View {
        ZStack {
            VisualAssetCard(assetName: "DeskScanVisual", height: 280)

            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text("Workspace scanner placeholder")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Camera framing plus setup questions produce ergonomic suggestions.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
    }
}
