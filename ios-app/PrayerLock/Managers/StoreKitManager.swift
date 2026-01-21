import Foundation
import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    // Mock product IDs
    private let productDict: [String: String] = [
        "com.prayerlock.monthly": "Monthly Subscription",
        "com.prayerlock.yearly": "Yearly Subscription"
    ]
    
    init() {
        // In a real app, we would listen for transaction updates here
        Task {
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: productDict.keys)
            self.products = storeProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            if let transaction = try? verification.payloadValue {
                await transaction.finish()
                await updatePurchasedProducts()
            }
        case .userCancelled:
            break
        case .pending:
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    var hasActiveSubscription: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
}
