import Foundation
import SwiftData

@MainActor
final class DeskScannerViewModel: ObservableObject {
    @Published var workspaceNotes = ""
    @Published var monitorNearEyeLevel = false
    @Published var feetSupported = false
    @Published var keyboardClose = true
    @Published var softLighting = true
    @Published var isScanning = false
    @Published var result: ErgonomicSuggestionResult?
    @Published var errorMessage: String?

    func generateScan(aiService: any AIService, context: ModelContext) async {
        isScanning = true
        defer { isScanning = false }

        let questionNotes = [
            "Monitor near eye level: \(monitorNearEyeLevel)",
            "Feet supported: \(feetSupported)",
            "Keyboard close: \(keyboardClose)",
            "Soft lighting: \(softLighting)",
            workspaceNotes
        ].joined(separator: "\n")

        do {
            let generated = try await aiService.generateErgonomicSuggestions(notes: questionNotes)
            result = generated
            context.insert(
                DeskSetupScan(
                    setupScore: generated.setupScore,
                    recommendations: generated.recommendations,
                    workspaceNotes: questionNotes
                )
            )
            try? context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
