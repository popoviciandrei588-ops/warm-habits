import Foundation
import StoreKit

/// Manager for handling StoreKit 2 subscriptions
@MainActor
final class SubscriptionManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = SubscriptionManager()
    
    // MARK: - Product Identifiers
    enum ProductID: String, CaseIterable {
        case weeklySubscription = "com.prayerlock.subscription.weekly"
        case monthlySubscription = "com.prayerlock.subscription.monthly"
        case yearlySubscription = "com.prayerlock.subscription.yearly"
        case lifetimeAccess = "com.prayerlock.lifetime"
        
        var displayName: String {
            switch self {
            case .weeklySubscription: return "Weekly"
            case .monthlySubscription: return "Monthly"
            case .yearlySubscription: return "Yearly"
            case .lifetimeAccess: return "Lifetime"
            }
        }
        
        var description: String {
            switch self {
            case .weeklySubscription: return "Billed weekly"
            case .monthlySubscription: return "Billed monthly"
            case .yearlySubscription: return "Billed yearly (Save 50%)"
            case .lifetimeAccess: return "One-time purchase"
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var error: SubscriptionError?
    @Published var hasActiveSubscription: Bool = false
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    private init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()
        
        // Load products and check subscription status
        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Load available products from the App Store
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: Set(productIDs))
            products.sort { p1, p2 in
                // Sort by price (lowest first)
                p1.price < p2.price
            }
        } catch {
            self.error = .failedToLoadProducts(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase
    
    /// Purchase a product
    /// - Parameter product: The product to purchase
    /// - Returns: Whether the purchase was successful
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        error = nil
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Check if the transaction is verified
                switch verification {
                case .verified(let transaction):
                    // Deliver content
                    await transaction.finish()
                    await checkSubscriptionStatus()
                    isLoading = false
                    return true
                    
                case .unverified(_, let error):
                    self.error = .verificationFailed(error)
                    isLoading = false
                    return false
                }
                
            case .userCancelled:
                isLoading = false
                return false
                
            case .pending:
                self.error = .purchasePending
                isLoading = false
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            self.error = .purchaseFailed(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        error = nil
        
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            self.error = .restoreFailed(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Subscription Status
    
    /// Check the current subscription status
    func checkSubscriptionStatus() async {
        var hasValidSubscription = false
        
        // Check for active subscriptions
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.revocationDate == nil {
                    purchasedProductIDs.insert(transaction.productID)
                    hasValidSubscription = true
                }
            case .unverified:
                continue
            }
        }
        
        hasActiveSubscription = hasValidSubscription
    }
    
    /// Check if a specific product is purchased
    func isPurchased(_ productID: ProductID) -> Bool {
        purchasedProductIDs.contains(productID.rawValue)
    }
    
    /// Check if user has premium access
    var hasPremiumAccess: Bool {
        hasActiveSubscription || isPurchased(.lifetimeAccess)
    }
    
    // MARK: - Transaction Listener
    
    /// Listen for transaction updates
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    await transaction.finish()
                    await self.checkSubscriptionStatus()
                case .unverified:
                    continue
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get product by ID
    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }
    
    /// Format price for display
    func formattedPrice(for product: Product) -> String {
        product.displayPrice
    }
    
    /// Get the most popular product (for highlighting)
    var mostPopularProduct: Product? {
        product(for: .yearlySubscription)
    }
    
    /// Get the best value product
    var bestValueProduct: Product? {
        product(for: .lifetimeAccess)
    }
}

// MARK: - Subscription Errors
enum SubscriptionError: LocalizedError {
    case failedToLoadProducts(Error)
    case purchaseFailed(Error)
    case verificationFailed(Error)
    case purchasePending
    case restoreFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadProducts(let error):
            return "Failed to load products: \(error.localizedDescription)"
        case .purchaseFailed(let error):
            return "Purchase failed: \(error.localizedDescription)"
        case .verificationFailed(let error):
            return "Transaction verification failed: \(error.localizedDescription)"
        case .purchasePending:
            return "Purchase is pending approval"
        case .restoreFailed(let error):
            return "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
}

// MARK: - Mock Products for Preview/Testing
#if DEBUG
extension SubscriptionManager {
    /// Create mock products for preview
    static var mockProducts: [MockProduct] {
        [
            MockProduct(id: ProductID.weeklySubscription.rawValue, displayName: "Weekly", price: 4.99, description: "Billed weekly"),
            MockProduct(id: ProductID.monthlySubscription.rawValue, displayName: "Monthly", price: 9.99, description: "Billed monthly"),
            MockProduct(id: ProductID.yearlySubscription.rawValue, displayName: "Yearly", price: 49.99, description: "Billed yearly - Save 50%!"),
            MockProduct(id: ProductID.lifetimeAccess.rawValue, displayName: "Lifetime", price: 99.99, description: "One-time purchase")
        ]
    }
}

struct MockProduct: Identifiable {
    let id: String
    let displayName: String
    let price: Decimal
    let description: String
    
    var displayPrice: String {
        "$\(price)"
    }
}
#endif
