import SwiftUI
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    
    // MARK: - Product IDs
    static let monthlyProductID = "com.prayerlock.monthly"
    static let yearlyProductID = "com.prayerlock.yearly"
    static let lifetimeProductID = "com.prayerlock.lifetime"
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    var monthlyProduct: Product? {
        products.first { $0.id == Self.monthlyProductID }
    }
    
    var yearlyProduct: Product? {
        products.first { $0.id == Self.yearlyProductID }
    }
    
    var lifetimeProduct: Product? {
        products.first { $0.id == Self.lifetimeProductID }
    }
    
    // MARK: - Initialization
    init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
            await listenForTransactions()
        }
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        
        do {
            let productIDs: Set<String> = [
                Self.monthlyProductID,
                Self.yearlyProductID,
                Self.lifetimeProductID
            ]
            
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await updatePurchasedProducts()
            return true
            
        case .userCancelled:
            return false
            
        case .pending:
            return false
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Update Purchased Products
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            
            if transaction.revocationDate == nil {
                purchasedIDs.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchasedIDs
    }
    
    // MARK: - Listen for Transactions
    func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else { continue }
            await transaction.finish()
            await updatePurchasedProducts()
        }
    }
    
    // MARK: - Verify Transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Store Error
enum StoreError: Error, LocalizedError {
    case failedVerification
    case purchaseFailed
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed."
        case .purchaseFailed:
            return "Purchase could not be completed."
        }
    }
}

// MARK: - Product Extension for Display
extension Product {
    var displayPrice: String {
        displayPrice
    }
    
    var periodText: String {
        guard let subscription = subscription else { return "" }
        
        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value
        
        switch unit {
        case .day:
            return value == 1 ? "day" : "\(value) days"
        case .week:
            return value == 1 ? "week" : "\(value) weeks"
        case .month:
            return value == 1 ? "month" : "\(value) months"
        case .year:
            return value == 1 ? "year" : "\(value) years"
        @unknown default:
            return ""
        }
    }
}
