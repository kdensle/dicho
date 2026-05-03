import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    nonisolated static let proMonthlyProductID = "dicho.pro.monthly"

    @Published private(set) var proMonthlyProduct: Product?
    @Published private(set) var hasActiveSubscription = false
    @Published private(set) var isLoadingProducts = false
    @Published var message: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = listenForTransactions()

        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var priceText: String {
        proMonthlyProduct?.displayPrice ?? "$2.99"
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let products = try await Product.products(for: [Self.proMonthlyProductID])
            proMonthlyProduct = products.first

            if products.isEmpty {
                message = "Subscription is not configured in App Store Connect yet."
            }
        } catch {
            message = "Could not load subscription options."
        }
    }

    func purchaseProMonthly() async {
        guard let product = proMonthlyProduct else {
            message = "Subscription is not available in this build yet."
            return
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                message = "dicho pro is active."
            case .userCancelled:
                message = nil
            case .pending:
                message = "Purchase is pending approval."
            @unknown default:
                message = "Purchase could not be completed."
            }
        } catch {
            message = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            message = hasActiveSubscription ? "Purchases restored." : "No active subscription found."
        } catch {
            message = "Could not restore purchases."
        }
    }

    func refreshEntitlements() async {
        var isSubscribed = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else {
                continue
            }

            if transaction.productID == Self.proMonthlyProductID {
                isSubscribed = true
            }
        }

        hasActiveSubscription = isSubscribed
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                guard let transaction = try? checkVerified(result) else {
                    continue
                }

                await transaction.finish()
                await refreshEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SubscriptionError.unverifiedTransaction
        }
    }
}

private enum SubscriptionError: Error {
    case unverifiedTransaction
}
