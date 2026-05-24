import SwiftUI

struct DeskSetupCard: View {
    var score: Int
    var recommendations: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Desk setup score")
                        .font(.headline)
                    Text("Ergonomics suggestions are informational wellness guidance.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(score)")
                    .font(.title.bold())
                    .foregroundStyle(Color.ppCyan)
                    .contentTransition(.numericText())
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(recommendations, id: \.self) { recommendation in
                    Label(recommendation, systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .cardStyle()
    }
}
