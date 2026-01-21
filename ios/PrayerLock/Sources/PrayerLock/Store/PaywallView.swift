import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Prayer Lock")
                        .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                    Text("A faith-first pause before distracting apps.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(title: "Block distracting apps", subtitle: "Create space for prayer before you scroll.")
                    FeatureRow(title: "Personalized prayers", subtitle: "Bible-rooted prayers matched to your mood.")
                    FeatureRow(title: "Streaks + journey analytics", subtitle: "Track sessions, time prayed, and moods.")
                    FeatureRow(title: "Verse screen", subtitle: "A delightful scripture moment each day.")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                VStack(spacing: 10) {
                    if subscriptionManager.products.isEmpty {
                        ProgressView()
                            .padding(.vertical, 12)
                    } else {
                        ForEach(subscriptionManager.products, id: \.id) { product in
                            Button {
                                Task { await subscriptionManager.purchase(product) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.displayPrice)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("Continue")
                                        .font(.headline)
                                }
                                .padding(14)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button("Restore purchases") {
                        Task { await subscriptionManager.restorePurchases() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .padding(.top, 4)

                    if let msg = subscriptionManager.lastErrorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 6) {
                        Text("Terms & Privacy")
                            .font(.footnote.weight(.semibold))
                        Text("Placeholder links for Terms of Service and Privacy Policy.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.vertical, 24)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.9),
                        Color(.systemBackground).opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

private struct FeatureRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

