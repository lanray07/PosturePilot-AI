import Charts
import SwiftUI

struct InsightChartCard: View {
    var title: String
    var subtitle: String
    var samples: [TrendSample]
    var tint: Color = .ppCyan

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            if samples.isEmpty {
                ContentUnavailableView("No data yet", systemImage: "chart.line.uptrend.xyaxis", description: Text("Your trend appears after a few posture checks."))
                    .frame(height: 180)
            } else {
                Chart(samples) { sample in
                    LineMark(
                        x: .value("Day", sample.label),
                        y: .value("Value", sample.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(tint)

                    AreaMark(
                        x: .value("Day", sample.label),
                        y: .value("Value", sample.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [tint.opacity(0.32), tint.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
            }
        }
        .cardStyle()
    }
}
