import SwiftUI

struct LoadingStateView: View {
    var title: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(.ppCyan)
            Text(title)
                .font(.subheadline.weight(.semibold))
            Spacer()
        }
        .cardStyle()
    }
}

struct EmptyStateView: View {
    var title: String
    var subtitle: String
    var icon: String
    var assetName: String? = nil

    var body: some View {
        VStack(spacing: 10) {
            if let assetName {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 126)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(Color.ppCyan)
            }
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

struct ErrorStateView: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(Color.ppAmber)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
