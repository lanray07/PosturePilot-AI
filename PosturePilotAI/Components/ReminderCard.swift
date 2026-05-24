import SwiftUI

struct ReminderCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.ppAmber)
                .frame(width: 42, height: 42)
                .background(Color.ppAmber.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(actionTitle, action: action)
                .font(.caption.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(.ppBlue)
        }
        .cardStyle()
    }
}
