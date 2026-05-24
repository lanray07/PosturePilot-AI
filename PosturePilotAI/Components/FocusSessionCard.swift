import SwiftUI

struct FocusSessionCard: View {
    var mode: FocusMode
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.title3)
                    .frame(width: 34, height: 34)
                    .background((isSelected ? Color.ppCyan : Color.white.opacity(0.08)).opacity(0.16), in: Circle())
                    .foregroundStyle(isSelected ? Color.ppCyan : Color.white.opacity(0.72))

                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title)
                        .font(.headline)
                    Text("\(mode.defaultMinutes) min default")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.ppCyan : Color.white.opacity(0.28))
            }
            .foregroundStyle(.primary)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
