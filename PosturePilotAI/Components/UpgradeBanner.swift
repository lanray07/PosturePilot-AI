import SwiftUI

struct UpgradeBanner: View {
    var title: String = "Unlock deeper posture insights"
    var subtitle: String = "AI analysis, unlimited focus sessions, ergonomics scans, widgets, and Watch placeholders."

    var body: some View {
        NavigationLink(value: AppRoute.paywall) {
            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(Color.ppCyan)
                    .frame(width: 42, height: 42)
                    .background(Color.ppCyan.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}
