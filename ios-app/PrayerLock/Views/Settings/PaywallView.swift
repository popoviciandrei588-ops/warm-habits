import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var storeKitManager = StoreKitManager.shared
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Text("Unlock Full Access")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(text: "Unlimited Prayers")
                FeatureRow(text: "Custom Lock Durations")
                FeatureRow(text: "Prayer Journey Analytics")
                FeatureRow(text: "All Prayer Themes")
            }
            .padding()
            
            Spacer()
            
            if storeKitManager.products.isEmpty {
                ProgressView("Loading products...")
            } else {
                ForEach(storeKitManager.products) { product in
                    Button(action: {
                        Task {
                            try? await storeKitManager.purchase(product)
                        }
                    }) {
                        HStack {
                            Text(product.displayName)
                            Spacer()
                            Text(product.displayPrice)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            
            Button("Restore Purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.top)
            
            Text("Subscription required for all features.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .onAppear {
            Task {
                await storeKitManager.loadProducts()
            }
        }
    }
}

struct FeatureRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
                .font(.body)
        }
    }
}
