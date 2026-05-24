import SwiftUI

struct WellnessDisclaimerView: View {
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 8 : 12) {
            Label("Wellness disclaimer", systemImage: "heart.text.square")
                .font(compact ? .subheadline.weight(.semibold) : .headline)
                .foregroundStyle(Color.ppAmber)

            Text(WellnessDisclaimer.short)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !compact {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(WellnessDisclaimer.statements, id: \.self) { statement in
                        Label(statement, systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .cardStyle()
    }
}
