import SwiftUI
import StoreKit

/// Subscription paywall view
struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProductIndex = 1 // Default to monthly
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.08, blue: 0.18),
                        Color(red: 0.15, green: 0.12, blue: 0.25)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Close button
                        HStack {
                            Spacer()
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        // Header
                        headerSection
                        
                        // Features
                        featuresSection
                        
                        // Pricing options
                        pricingSection
                        
                        // Subscribe button
                        subscribeButton
                        
                        // Restore and legal
                        legalSection
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App icon/logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("🙏")
                    .font(.system(size: 40))
            }
            
            Text("Prayer Lock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Transform your screen time into sacred moments")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(
                icon: "lock.shield.fill",
                title: "App Blocking",
                description: "Block distracting apps until you pray"
            )
            
            FeatureRow(
                icon: "text.book.closed.fill",
                title: "Personalized Prayers",
                description: "Prayers tailored to your mood and needs"
            )
            
            FeatureRow(
                icon: "flame.fill",
                title: "Streak Tracking",
                description: "Build consistent prayer habits"
            )
            
            FeatureRow(
                icon: "book.fill",
                title: "Daily Verses",
                description: "Beautiful scripture to start your day"
            )
            
            FeatureRow(
                icon: "chart.bar.fill",
                title: "Prayer Analytics",
                description: "Track your spiritual journey"
            )
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    // MARK: - Pricing Section
    private var pricingSection: some View {
        VStack(spacing: 12) {
            // Using mock products for display
            let mockProducts = SubscriptionManager.mockProducts
            
            ForEach(Array(mockProducts.enumerated()), id: \.element.id) { index, product in
                PricingOption(
                    title: product.displayName,
                    price: product.displayPrice,
                    description: product.description,
                    isSelected: selectedProductIndex == index,
                    isPopular: index == 2 // Yearly is popular
                ) {
                    selectedProductIndex = index
                }
            }
        }
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        Button(action: subscribe) {
            HStack {
                if subscriptionManager.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Free Trial")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
        }
        .disabled(subscriptionManager.isLoading)
    }
    
    // MARK: - Legal Section
    private var legalSection: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    showTerms = true
                }
                
                Text("•")
                    .foregroundColor(.white.opacity(0.3))
                
                Button("Privacy Policy") {
                    showPrivacy = true
                }
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
            
            Text("Cancel anytime. Subscription auto-renews until canceled.")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .sheet(isPresented: $showTerms) {
            LegalView(title: "Terms of Service", content: termsContent)
        }
        .sheet(isPresented: $showPrivacy) {
            LegalView(title: "Privacy Policy", content: privacyContent)
        }
    }
    
    // MARK: - Helper Methods
    
    private func subscribe() {
        // In production, this would use the actual product from subscriptionManager.products
        Task {
            if let product = subscriptionManager.products.first {
                let _ = await subscriptionManager.purchase(product)
                if subscriptionManager.hasPremiumAccess {
                    dismiss()
                }
            }
        }
    }
    
    private var termsContent: String {
        """
        Terms of Service
        
        Last updated: January 2025
        
        1. Acceptance of Terms
        By using Prayer Lock, you agree to these terms of service.
        
        2. Subscription
        - Prayer Lock offers auto-renewable subscriptions
        - Payment is charged to your Apple ID account
        - Subscription auto-renews unless canceled 24 hours before the end of the current period
        - Manage subscriptions in your App Store account settings
        
        3. Privacy
        We respect your privacy. See our Privacy Policy for details.
        
        4. Limitation of Liability
        Prayer Lock is provided "as is" without warranties of any kind.
        
        5. Contact
        For questions, contact support@prayerlock.app
        """
    }
    
    private var privacyContent: String {
        """
        Privacy Policy
        
        Last updated: January 2025
        
        1. Data Collection
        Prayer Lock collects minimal data necessary to provide our service:
        - Prayer session data (stored locally on your device)
        - App blocking preferences (stored locally)
        - Subscription status
        
        2. Data Storage
        All prayer and personal data is stored locally on your device using SwiftData.
        
        3. Third Parties
        We do not sell or share your personal data with third parties.
        
        4. Screen Time
        We use Apple's Screen Time APIs to enable app blocking features. This data is processed locally and is not transmitted to our servers.
        
        5. Analytics
        We may collect anonymous usage analytics to improve the app.
        
        6. Contact
        For privacy questions, contact privacy@prayerlock.app
        """
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.indigo)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

struct PricingOption: View {
    let title: String
    let price: String
    let description: String
    let isSelected: Bool
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isPopular {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text(price)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.indigo.opacity(0.3) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.indigo : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

struct LegalView: View {
    let title: String
    let content: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .font(.body)
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
}
