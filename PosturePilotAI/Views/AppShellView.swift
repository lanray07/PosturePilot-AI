import SwiftData
import SwiftUI

struct AppShellView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var subscriptionStore = SubscriptionStore()

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Today", systemImage: "gauge.with.dots.needle.67percent") }

            NavigationStack {
                FocusSessionsView()
            }
            .tabItem { Label("Focus", systemImage: "timer") }

            NavigationStack {
                StretchRoutinesView()
            }
            .tabItem { Label("Recover", systemImage: "figure.cooldown") }

            NavigationStack {
                InsightsView()
            }
            .tabItem { Label("Insights", systemImage: "chart.line.uptrend.xyaxis") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .environmentObject(subscriptionStore)
        .task {
            SeedDataService.seedDefaultsIfNeeded(in: modelContext)
            await subscriptionStore.loadProducts()
            await subscriptionStore.refreshPurchasedProducts()
        }
    }
}
