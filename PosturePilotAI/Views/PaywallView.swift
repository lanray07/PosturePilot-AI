import StoreKit
import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var subscriptionStore: SubscriptionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                ForEach([SubscriptionPlan.free, .proMonthly, .proYearly, .eliteMonthly]) { plan in
                    planCard(plan)
                }

                if subscriptionStore.isLoading {
                    LoadingStateView(title: "Loading StoreKit products")
                }

                if let errorMessage = subscriptionStore.errorMessage {
                    ErrorStateView(title: "StoreKit placeholder", message: errorMessage)
                }

                subscriptionDisclosure
                WellnessDisclaimerView()
            }
            .padding(18)
        }
        .navigationTitle("Upgrade")
        .appBackground()
        .task {
            await subscriptionStore.loadProducts()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            PillLabel(title: "Subscriptions", icon: "crown")
            VisualAssetCard(
                assetName: "PremiumPlansVisual",
                height: 214,
                title: "Premium posture intelligence",
                subtitle: "Advanced insights, reports, and productivity-aware coaching."
            )
            Text("Choose the posture habit toolkit that fits your desk routine.")
                .font(.title2.bold())
                .fixedSize(horizontal: false, vertical: true)
            Text("Prices are placeholders until App Store Connect products are configured.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func planCard(_ plan: SubscriptionPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.title3.bold())
                    Text(plan == .free ? "Starter posture habits" : "Premium posture coaching tools")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.price)
                        .font(.title3.bold())
                        .foregroundStyle(plan == .eliteMonthly ? Color.ppAmber : Color.ppCyan)
                    Text(plan.duration)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.includedFeatures, id: \.self) { feature in
                    Label(feature, systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if plan == .free {
                Text(subscriptionStore.activePlan == .free ? "Current plan" : "Included")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    Task { await purchase(plan) }
                } label: {
                    Label(buttonTitle(for: plan), systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(plan == .eliteMonthly ? .ppAmber : .ppCyan)
            }
        }
        .cardStyle()
    }

    private var subscriptionDisclosure: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Purchases are charged through your Apple ID and can be managed in your App Store account settings.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                Link("Terms of Use", destination: LegalLinks.terms)
                Link("Privacy Policy", destination: LegalLinks.privacy)
                Link("Support", destination: LegalLinks.support)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.ppCyan)
        }
        .cardStyle()
    }

    private func buttonTitle(for plan: SubscriptionPlan) -> String {
        if subscriptionStore.activePlan == plan { return "Active" }
        return "Continue with \(plan.title)"
    }

    private func purchase(_ plan: SubscriptionPlan) async {
        guard let productID = plan.productID,
              let product = subscriptionStore.products.first(where: { $0.id == productID }) else {
            subscriptionStore.errorMessage = "This StoreKit product is not configured yet. Add products in App Store Connect or a local StoreKit configuration file."
            return
        }

        await subscriptionStore.purchase(product)
    }
}
