import SwiftUI

struct VisualAssetCard: View {
    var assetName: String
    var height: CGFloat
    var overlayAlignment: Alignment = .bottomLeading
    var title: String?
    var subtitle: String?

    var body: some View {
        ZStack(alignment: overlayAlignment) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
                .clipped()

            LinearGradient(
                colors: [.black.opacity(0.08), .black.opacity(0.48)],
                startPoint: .top,
                endPoint: .bottom
            )

            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 6) {
                    if let title {
                        Text(title)
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.82))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(18)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: Color.ppCyan.opacity(0.12), radius: 22, x: 0, y: 10)
    }
}
