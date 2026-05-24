import SwiftUI

extension Color {
    static let ppBackground = Color(red: 0.03, green: 0.06, blue: 0.12)
    static let ppSurface = Color(red: 0.07, green: 0.11, blue: 0.18)
    static let ppSurfaceRaised = Color(red: 0.10, green: 0.16, blue: 0.24)
    static let ppCyan = Color(red: 0.22, green: 0.86, blue: 0.96)
    static let ppTeal = Color(red: 0.13, green: 0.75, blue: 0.66)
    static let ppBlue = Color(red: 0.18, green: 0.34, blue: 0.92)
    static let ppAmber = Color(red: 1.0, green: 0.74, blue: 0.28)
    static let ppCoral = Color(red: 1.0, green: 0.36, blue: 0.42)
}

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [.ppBackground, Color(red: 0.03, green: 0.09, blue: 0.13), .black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.ppSurface.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }

    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

struct PillLabel: View {
    var title: String
    var icon: String
    var tint: Color = .ppCyan

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12), in: Capsule())
    }
}
