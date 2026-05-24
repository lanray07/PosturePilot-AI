import SwiftUI

struct StretchRoutineCard: View {
    var routine: StretchRoutine
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.ppTeal.opacity(0.16))
                    Image(systemName: routine.category.icon)
                        .font(.title3)
                        .foregroundStyle(Color.ppTeal)
                }
                .frame(width: 46, height: 46)

                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.headline)
                    Text("\(routine.category.title) - \(Int(routine.duration / 60)) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: routine.completed ? "checkmark.seal.fill" : "play.circle.fill")
                    .font(.title3)
                    .foregroundStyle(routine.completed ? Color.ppTeal : Color.ppCyan)
            }
            .foregroundStyle(.primary)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
