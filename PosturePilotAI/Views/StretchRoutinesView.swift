import SwiftData
import SwiftUI

struct StretchRoutinesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appServices: AppServices
    @Query(sort: \StretchRoutine.title) private var routines: [StretchRoutine]
    @StateObject private var viewModel = StretchRoutinesViewModel()
    @State private var pulse = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                categoryPicker

                if let activeRoutine = viewModel.activeRoutine {
                    activeRoutineView(activeRoutine)
                }

                if routines.isEmpty {
                    EmptyStateView(title: "No routines yet", subtitle: "Default routines are seeded when the app launches.", icon: "figure.cooldown")
                } else {
                    ForEach(filteredRoutines) { routine in
                        StretchRoutineCard(routine: routine) {
                            viewModel.start(routine)
                        }
                    }
                }

                recommendationsView
                WellnessDisclaimerView(compact: true)
            }
            .padding(18)
        }
        .navigationTitle("Recover")
        .appBackground()
        .task {
            await viewModel.loadRecommendations(aiService: appServices.aiService)
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            Task { await viewModel.loadRecommendations(aiService: appServices.aiService) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            PillLabel(title: "Stretch and recovery", icon: "figure.cooldown")
            Text("Short reset routines for desk-heavy days.")
                .font(.title2.bold())
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button {
                    viewModel.selectedCategory = nil
                } label: {
                    PillLabel(title: "All", icon: "square.grid.2x2", tint: viewModel.selectedCategory == nil ? .ppCyan : .secondary)
                }
                .buttonStyle(.plain)

                ForEach(StretchCategory.allCases) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        PillLabel(title: category.title, icon: category.icon, tint: viewModel.selectedCategory == category ? .ppCyan : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var filteredRoutines: [StretchRoutine] {
        guard let selectedCategory = viewModel.selectedCategory else { return routines }
        return routines.filter { $0.category == selectedCategory }
    }

    private func activeRoutineView(_ routine: StretchRoutine) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.ppTeal.opacity(pulse ? 0.26 : 0.10))
                    .frame(width: 150, height: 150)
                    .scaleEffect(pulse ? 1.08 : 0.92)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                Image(systemName: routine.category.icon)
                    .font(.system(size: 54))
                    .foregroundStyle(Color.ppTeal)
            }
            .onAppear { pulse = true }

            Text(routine.title)
                .font(.title3.bold())
            Text("\(viewModel.remainingSeconds)s")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            HStack {
                Button("Complete") {
                    viewModel.completeActiveRoutine(in: modelContext)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ppTeal)

                Button("Cancel") {
                    viewModel.cancel()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    private var recommendationsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI stretch recommendations")
                .font(.headline)
            ForEach(viewModel.recommendations) { recommendation in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendation.title)
                            .font(.subheadline.weight(.semibold))
                        Text("\(recommendation.category) - \(recommendation.durationSeconds)s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .cardStyle()
            }
        }
    }
}
