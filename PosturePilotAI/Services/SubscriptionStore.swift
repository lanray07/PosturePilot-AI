import Foundation
import StoreKit

@MainActor
final class SubscriptionStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var activePlan: SubscriptionPlan = .free
    @Published private(set) var renewsAt: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let productIDs = SubscriptionPlan.allCases.compactMap(\.productID)
    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactions()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
            errorMessage = nil
        } catch {
            errorMessage = "StoreKit products are placeholders until configured in App Store Connect or a StoreKit file."
            products = []
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    errorMessage = "The purchase could not be verified."
                    return
                }
                await transaction.finish()
                await refreshPurchasedProducts()
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "The purchase could not be completed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshPurchasedProducts() async {
        var bestPlan: SubscriptionPlan = .free
        var renewalDate: Date?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.revocationDate == nil,
                  let plan = SubscriptionPlan.allCases.first(where: { $0.productID == transaction.productID }) else {
                continue
            }

            if plan == .eliteMonthly {
                bestPlan = .eliteMonthly
            } else if bestPlan == .free {
                bestPlan = plan
            }
            renewalDate = transaction.expirationDate
        }

        activePlan = bestPlan
        renewsAt = renewalDate
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshPurchasedProducts()
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }
}
