import SwiftData
import SwiftUI

struct AchievementsView: View {
    @Query(sort: \Achievement.title) private var achievements: [Achievement]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Celebrate small posture habit wins.")
                    .font(.title2.bold())
                    .fixedSize(horizontal: false, vertical: true)

                if achievements.isEmpty {
                    EmptyStateView(title: "No badges yet", subtitle: "Achievements are seeded when the app starts.", icon: "rosette")
                } else {
                    if let unlocked = achievements.first(where: \.unlocked) {
                        ShareInviteCard(context: .achievement(unlocked.title), tint: .ppAmber)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                        ForEach(achievements) { achievement in
                            AchievementBadge(achievement: achievement)
                        }
                    }
                }
            }
            .padding(18)
        }
        .navigationTitle("Achievements")
        .appBackground()
    }
}
