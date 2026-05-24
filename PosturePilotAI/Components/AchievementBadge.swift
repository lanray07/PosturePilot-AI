import SwiftUI

struct AchievementBadge: View {
    var achievement: Achievement

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(achievement.unlocked ? Color.ppCyan : Color.white.opacity(0.32))
                .frame(width: 54, height: 54)
                .background(
                    Circle()
                        .fill(achievement.unlocked ? Color.ppCyan.opacity(0.14) : Color.white.opacity(0.06))
                )

            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(achievement.unlocked ? "Unlocked" : "Locked")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(achievement.unlocked ? Color.ppTeal : Color.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 146)
        .cardStyle()
        .opacity(achievement.unlocked ? 1 : 0.62)
    }
}
