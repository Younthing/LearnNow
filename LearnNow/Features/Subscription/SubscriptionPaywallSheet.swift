import SwiftUI

struct SubscriptionPaywallSheet: View {
    @Bindable var store: LearnNowAppStore

    @Environment(\.dismiss) private var dismiss
    @State private var selectedProductID: String?
    @State private var didSucceed = false

    private var products: [SubscriptionProductOffer] {
        store.subscriptionStore.products
    }

    private var purchaseState: SubscriptionPurchaseState {
        store.subscriptionStore.purchaseState
    }

    private var localizedError: String? {
        store.subscriptionStore.localizedError
    }

    private var isBusy: Bool {
        purchaseState == .purchasing || purchaseState == .restoring
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    productOptions
                    actions
                    footer
                }
                .padding(24)
            }
            .background(LearnNowPalette.canvas.ignoresSafeArea())
            .navigationTitle("云同步")
            .learnNowInlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .disabled(isBusy)
                }
            }
            .task {
                if products.isEmpty {
                    await store.subscriptionStore.loadProducts()
                }
                if selectedProductID == nil {
                    selectedProductID = products.first?.id
                        ?? LearnNowProductID.cloudSyncYearly
                }
            }
        }
        .accessibilityIdentifier("sheet.subscription.paywall")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("跨设备同步学习进度")
                .font(LearnNowTypography.screenTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            Text("订阅后可开启 iCloud 云同步，在多台设备间合并学习进度、复习记录与个人资料。课程学习、Anki 复习与路径本身保持免费。")
                .font(LearnNowTypography.body)
                .foregroundStyle(LearnNowPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var productOptions: some View {
        VStack(spacing: 12) {
            ForEach(products) { product in
                Button {
                    selectedProductID = product.id
                } label: {
                    HStack(alignment: .center, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(product.displayName)
                                .font(LearnNowTypography.cardTitle)
                                .foregroundStyle(LearnNowPalette.textPrimary)
                            Text(product.periodLabel)
                                .font(LearnNowTypography.metadata)
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }

                        Spacer(minLength: 8)

                        Text(product.displayPrice)
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowSemanticRole.brand.foreground)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(OuterSurface(cornerRadius: 20))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                selectedProductID == product.id
                                    ? LearnNowSemanticRole.brand.foreground
                                    : Color.clear,
                                lineWidth: 2
                            )
                    }
                }
                .buttonStyle(.plain)
                .disabled(isBusy)
                .accessibilityIdentifier("subscription.product.\(product.id)")
                .accessibilityValue(selectedProductID == product.id ? "已选择" : "")
            }

            if products.isEmpty {
                Text("正在加载订阅方案…")
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var actions: some View {
        VStack(spacing: 12) {
            FullWidthButton(
                title: purchaseButtonTitle,
                role: .brand,
                systemImage: "icloud.fill"
            ) {
                Task { await purchaseSelected() }
            }
            .disabled(selectedProductID == nil || isBusy)
            .opacity(selectedProductID == nil || isBusy ? 0.6 : 1)
            .accessibilityIdentifier("subscription.purchase")

            Button {
                Task { await restore() }
            } label: {
                Text(purchaseState == .restoring ? "正在恢复…" : "恢复购买")
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .disabled(isBusy)
            .accessibilityIdentifier("subscription.restore")

            if let localizedError, !didSucceed {
                Text(localizedError)
                    .font(LearnNowTypography.metadata)
                    .foregroundStyle(LearnNowSemanticRole.warning.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if didSucceed {
                Text("已开启云同步偏好。重新打开 App 后生效。")
                    .font(LearnNowTypography.metadata)
                    .foregroundStyle(LearnNowSemanticRole.brand.foreground)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var footer: some View {
        Text("订阅为自动续订。可随时在系统「订阅」中管理或取消。关闭或过期后不会删除本机与 iCloud 中已有记录。")
            .font(LearnNowTypography.metadata)
            .foregroundStyle(LearnNowPalette.textMuted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var purchaseButtonTitle: String {
        switch purchaseState {
        case .purchasing:
            "正在购买…"
        case .restoring:
            "正在恢复…"
        case .idle, .failed:
            "订阅并开启同步"
        }
    }

    private func purchaseSelected() async {
        guard let selectedProductID else { return }
        let success = await store.purchaseCloudSync(productID: selectedProductID)
        if success {
            didSucceed = true
            dismiss()
        }
    }

    private func restore() async {
        let success = await store.restorePurchases()
        if success {
            didSucceed = true
            dismiss()
        }
    }
}

#Preview {
    SubscriptionPaywallSheet(
        store: LearnNowAppStore(
            activeCloudSyncEnabled: false,
            subscriptionStore: SubscriptionStore(testingEntitlementOverride: false)
        )
    )
}
