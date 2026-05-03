import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var usageMeter: UsageMeter
    @State private var selectedLegalDocument: LegalDocument?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("dicho")
                            .dichoWordmark(size: 42)
                            .foregroundStyle(AppStyle.primaryAccent)

                        Text("Keep translating naturally")
                            .font(.title2.weight(.semibold))

                        Text("You used your \(UsageMeter.freeMonthlyLimit) free translations for this month. Upgrade to keep using country-aware AI translation.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        PaywallBenefit(systemImage: "arrow.left.arrow.right", title: "Unlimited translations", detail: "Translate English and Spanish without the monthly free limit.")
                        PaywallBenefit(systemImage: "globe.americas", title: "Country-aware Spanish", detail: "Keep the natural phrasing controls for Mexico, Spain, Colombia, Argentina, Chile, Peru, Puerto Rico, and U.S. Spanish.")
                        PaywallBenefit(systemImage: "doc.on.clipboard", title: "Auto copy stays fast", detail: "Output is copied after each successful translation.")
                    }
                    .padding(16)
                    .cardSurface()

                    VStack(spacing: 10) {
                        Button {
                            AppHaptics.lightImpact()
                            Task {
                                await subscriptionManager.purchaseProMonthly()
                                if subscriptionManager.hasActiveSubscription {
                                    AppHaptics.success()
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Start dicho pro - \(subscriptionManager.priceText)/month")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(TranslateButtonStyle())
                        .disabled(subscriptionManager.proMonthlyProduct == nil && !AppConfiguration.isScreenshotMode)

                        Button {
                            AppHaptics.lightImpact()
                            Task {
                                await subscriptionManager.restorePurchases()
                                if subscriptionManager.hasActiveSubscription {
                                    AppHaptics.success()
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.callout.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(AppStyle.primaryAccent)

                        if let message = subscriptionManager.message, !AppConfiguration.isScreenshotMode {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    Text("Auto-renewable monthly subscription. Payment is charged to your Apple Account at confirmation of purchase and renews unless canceled at least 24 hours before the end of the current period.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 14) {
                        Button("Terms") {
                            selectedLegalDocument = .terms
                        }

                        Button("Privacy") {
                            selectedLegalDocument = .privacy
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppStyle.primaryAccent)
                }
                .padding()
            }
            .background(AppStyle.groupedBackground)
            .navigationTitle("dicho pro")
            .compactNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not Now") {
                        AppHaptics.lightImpact()
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedLegalDocument) { document in
                NavigationStack {
                    LegalView(document: document)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    selectedLegalDocument = nil
                                }
                            }
                        }
                }
            }
            .task {
                if !AppConfiguration.isScreenshotMode {
                    await subscriptionManager.loadProducts()
                    await subscriptionManager.refreshEntitlements()
                }
            }
        }
    }
}

private struct PaywallBenefit: View {
    var systemImage: String
    var title: String
    var detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AppStyle.primaryAccent)
                .frame(width: 28, height: 28)
                .background(AppStyle.primaryAccent.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView()
            .environmentObject(SubscriptionManager())
            .environmentObject(UsageMeter())
    }
}
