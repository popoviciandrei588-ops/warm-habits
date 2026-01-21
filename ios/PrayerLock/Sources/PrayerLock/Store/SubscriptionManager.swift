import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    // Mock product IDs (replace with App Store Connect IDs).
    static let productIDs: [String] = [
        "com.example.prayerlock.monthly",
        "com.example.prayerlock.yearly"
    ]

    @Published private(set) var products: [Product] = []
    @Published private(set) var isSubscribed: Bool = false
    @Published var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await _ in Transaction.updates {
                await self.refreshEntitlements()
            }
        }

        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.productIDs)
        } catch {
            lastErrorMessage = "Unable to load subscription options."
        }
    }

    func purchase(_ product: Product) async {
        lastErrorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                await refreshEntitlements()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            lastErrorMessage = "Purchase failed. Please try again."
        }
    }

    func restorePurchases() async {
        lastErrorMessage = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastErrorMessage = "Restore failed. Please try again."
        }
    }

    func refreshEntitlements() async {
        var hasActiveSubscription = false
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productType == .autoRenewable {
                    hasActiveSubscription = true
                }
            } catch {
                // Ignore unverified entitlements.
            }
        }
        isSubscribed = hasActiveSubscription
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}

