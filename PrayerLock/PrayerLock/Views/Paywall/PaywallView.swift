import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var selectedProduct: Product?
    @State private var appear = false
    @State private var isPurchasing = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0F172A"),
                    Color(hex: "1E3A5F"),
                    Color(hex: "1E40AF").opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            FloatingOrbs()
            
            ScrollView {
                VStack(spacing: PLSpacing.xl) {
                    // Close button
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, PLSpacing.md)
                    
                    // Header
                    VStack(spacing: PLSpacing.md) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "F59E0B"), Color(hex: "EAB308")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .opacity(appear ? 1 : 0)
                            .scaleEffect(appear ? 1 : 0.5)
                        
                        Text("Unlock Prayer Lock")
                            .font(PLTypography.displaySmall)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                        
                        Text("Take control of your screen time\nwith the power of prayer")
                            .font(PLTypography.bodyMedium)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 20)
                    }
                    .padding(.top, PLSpacing.lg)
                    
                    // Features
                    VStack(spacing: PLSpacing.md) {
                        FeatureRow(icon: "lock.shield.fill", title: "Block Distracting Apps")
                        FeatureRow(icon: "hands.sparkles.fill", title: "Guided Prayer Flows")
                        FeatureRow(icon: "flame.fill", title: "Streak & Stats Tracking")
                        FeatureRow(icon: "book.fill", title: "Daily Verse Inspiration")
                    }
                    .padding(.horizontal, PLSpacing.lg)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    
                    // Product options
                    VStack(spacing: PLSpacing.sm) {
                        if subscriptionManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        } else {
                            ForEach(subscriptionManager.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id
                                ) {
                                    selectedProduct = product
                                }
                            }
                        }
                    }
                    .padding(.horizontal, PLSpacing.md)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    
                    // Purchase button
                    Button {
                        purchase()
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "1E3A5F")))
                            } else {
                                Text("Start Free Trial")
                            }
                        }
                        .font(PLTypography.titleMedium)
                        .foregroundColor(Color(hex: "1E3A5F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PLSpacing.md)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: PLRadius.lg))
                    }
                    .disabled(selectedProduct == nil || isPurchasing)
                    .opacity(selectedProduct != nil ? 1 : 0.5)
                    .padding(.horizontal, PLSpacing.lg)
                    .opacity(appear ? 1 : 0)
                    
                    // Restore & terms
                    VStack(spacing: PLSpacing.sm) {
                        Button {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(PLTypography.labelMedium)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        HStack(spacing: PLSpacing.md) {
                            Link("Privacy", destination: URL(string: "https://prayerlock.com/privacy")!)
                            Text("•")
                            Link("Terms", destination: URL(string: "https://prayerlock.com/terms")!)
                        }
                        .font(PLTypography.labelSmall)
                        .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.bottom, PLSpacing.xxl)
                    .opacity(appear ? 1 : 0)
                }
            }
        }
        .onAppear {
            if let first = subscriptionManager.products.first {
                selectedProduct = first
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appear = true
            }
        }
    }
    
    private func purchase() {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        
        Task {
            do {
                let success = try await subscriptionManager.purchase(product)
                if success {
                    dismiss()
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            isPurchasing = false
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: PLSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "3B82F6"))
                .frame(width: 32)
            
            Text(title)
                .font(PLTypography.bodyMedium)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "10B981"))
        }
        .padding(.vertical, PLSpacing.xs)
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: PLSpacing.xxs) {
                    HStack {
                        Text(productTitle)
                            .font(PLTypography.titleMedium)
                            .foregroundColor(.white)
                        
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(PLTypography.labelSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, PLSpacing.xs)
                                .padding(.vertical, 2)
                                .background(Color(hex: "10B981"))
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let period = product.subscription?.subscriptionPeriod {
                        Text(periodDescription(period))
                            .font(PLTypography.bodySmall)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(PLTypography.titleMedium)
                        .foregroundColor(.white)
                    
                    if let period = product.subscription?.subscriptionPeriod {
                        Text(pricePerMonth(product, period: period))
                            .font(PLTypography.labelSmall)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(PLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PLRadius.lg)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: PLRadius.lg)
                            .stroke(isSelected ? Color(hex: "3B82F6") : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var productTitle: String {
        if product.id.contains("yearly") {
            return "Yearly"
        } else if product.id.contains("monthly") {
            return "Monthly"
        } else if product.id.contains("lifetime") {
            return "Lifetime"
        }
        return product.displayName
    }
    
    private var isBestValue: Bool {
        product.id.contains("yearly")
    }
    
    private func periodDescription(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .year:
            return "Billed annually"
        case .month:
            return "Billed monthly"
        default:
            return ""
        }
    }
    
    private func pricePerMonth(_ product: Product, period: Product.SubscriptionPeriod) -> String {
        if period.unit == .year {
            let monthlyPrice = product.price / 12
            return String(format: "%.2f/mo", NSDecimalNumber(decimal: monthlyPrice).doubleValue)
        }
        return ""
    }
}

#Preview {
    PaywallView()
        .environmentObject(SubscriptionManager())
}
