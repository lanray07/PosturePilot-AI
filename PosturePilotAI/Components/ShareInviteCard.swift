import SwiftUI

struct ShareInviteCard: View {
    var context: GrowthShareContext
    var tint: Color = .ppCyan

    var body: some View {
        ShareLink(
            item: GrowthService.shareText(for: context),
            subject: Text("PosturePilot AI"),
            preview: SharePreview("PosturePilot AI", image: Image("ShareCardVisual"))
        ) {
            HStack(spacing: 14) {
                Image(systemName: context.icon)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(0.14), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.title)
                        .font(.headline)
                    Text(context.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(context.title)
    }
}
