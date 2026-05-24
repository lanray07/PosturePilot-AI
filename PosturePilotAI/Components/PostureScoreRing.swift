import SwiftUI

struct PostureScoreRing: View {
    var score: Int
    var size: CGFloat = 156
    var lineWidth: CGFloat = 15

    private var progress: Double {
        max(0, min(1, Double(score) / 100))
    }

    private var scoreColor: Color {
        switch score {
        case 86...100: .ppTeal
        case 70..<86: .ppAmber
        default: .ppCoral
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(colors: [.ppCyan, scoreColor, .ppBlue], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.65, dampingFraction: 0.78), value: score)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("posture score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Posture score \(score) out of 100")
    }
}
