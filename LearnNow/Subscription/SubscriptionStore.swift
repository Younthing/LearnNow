import Foundation
import Observation
import StoreKit

enum SubscriptionPurchaseState: Equatable, Sendable {
    case idle
    case purchasing
    case restoring
    case failed
}

struct SubscriptionProductOffer: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let displayPrice: String
    let periodLabel: String
}

@MainActor
protocol SubscriptionStoreProtocol: AnyObject {
    var isCloudSyncEntitled: Bool { get }
    var products: [SubscriptionProductOffer] { get }
    var purchaseState: SubscriptionPurchaseState { get }
    var localizedError: String? { get }

    func start() async
    func refreshEntitlements() async
    func purchase(productID: String) async throws
    func restore() async
}

@MainActor
@Observable
final class SubscriptionStore: SubscriptionStoreProtocol {
    private(set) var isCloudSyncEntitled = false
    private(set) var products: [SubscriptionProductOffer] = []
    private(set) var purchaseState: SubscriptionPurchaseState = .idle
    private(set) var localizedError: String?

    private var storeProductsByID: [String: Product] = [:]
    private var updatesTask: Task<Void, Never>?
    private let testingEntitlementOverride: Bool?
    private let defaults: UserDefaults
    private let processInfo: ProcessInfo

    init(
        testingEntitlementOverride: Bool? = nil,
        defaults: UserDefaults = .standard,
        processInfo: ProcessInfo = .processInfo
    ) {
        self.testingEntitlementOverride = testingEntitlementOverride
        self.defaults = defaults
        self.processInfo = processInfo
        self.isCloudSyncEntitled = resolvedTestingEntitlement()
            ?? SubscriptionEntitlement.isEntitled(in: defaults, processInfo: processInfo)
    }

    func start() async {
        await refreshEntitlements()
        await loadProducts()
        listenForTransactions()
    }

    func loadProducts() async {
        guard testingEntitlementOverride == nil else {
            products = [
                .init(
                    id: LearnNowProductID.cloudSyncMonthly,
                    displayName: "云同步 · 月订",
                    displayPrice: "¥6.00",
                    periodLabel: LearnNowProductID.periodLabel(for: LearnNowProductID.cloudSyncMonthly)
                ),
                .init(
                    id: LearnNowProductID.cloudSyncYearly,
                    displayName: "云同步 · 年订",
                    displayPrice: "¥48.00",
                    periodLabel: LearnNowProductID.periodLabel(for: LearnNowProductID.cloudSyncYearly)
                ),
            ]
            return
        }

        do {
            let loaded = try await Product.products(for: LearnNowProductID.cloudSyncAll)
            storeProductsByID = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
            let orderedIDs = [
                LearnNowProductID.cloudSyncMonthly,
                LearnNowProductID.cloudSyncYearly,
            ]
            products = orderedIDs.compactMap { id -> SubscriptionProductOffer? in
                guard let product = storeProductsByID[id] else { return nil }
                return SubscriptionProductOffer(
                    id: product.id,
                    displayName: product.displayName,
                    displayPrice: product.displayPrice,
                    periodLabel: LearnNowProductID.periodLabel(for: product.id)
                )
            }
        } catch {
            localizedError = error.localizedDescription
            purchaseState = .failed
        }
    }

    func refreshEntitlements() async {
        if let testingEntitlementOverride {
            applyEntitlement(testingEntitlementOverride)
            return
        }

        if processInfo.arguments.contains(SubscriptionEntitlement.uiTestingEntitledArgument) {
            applyEntitlement(true)
            return
        }

        if processInfo.arguments.contains("-UITestingResetData") {
            applyEntitlement(false)
            return
        }

        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if LearnNowProductID.cloudSyncAll.contains(transaction.productID) {
                entitled = true
                break
            }
        }
        applyEntitlement(entitled)
    }

    func purchase(productID: String) async throws {
        if testingEntitlementOverride != nil {
            purchaseState = .purchasing
            localizedError = nil
            applyEntitlement(true)
            purchaseState = .idle
            return
        }

        guard let product = storeProductsByID[productID] else {
            purchaseState = .failed
            localizedError = "暂时无法获取订阅产品，请稍后重试。"
            throw StoreError.productUnavailable
        }

        purchaseState = .purchasing
        localizedError = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                purchaseState = .idle
            case .userCancelled, .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed
            localizedError = error.localizedDescription
            throw error
        }
    }

    func restore() async {
        if testingEntitlementOverride != nil {
            purchaseState = .restoring
            localizedError = nil
            await refreshEntitlements()
            purchaseState = isCloudSyncEntitled ? .idle : .failed
            if !isCloudSyncEntitled {
                localizedError = "没有可恢复的云同步订阅。"
            }
            return
        }

        purchaseState = .restoring
        localizedError = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseState = isCloudSyncEntitled ? .idle : .failed
            if !isCloudSyncEntitled {
                localizedError = "没有可恢复的云同步订阅。"
            }
        } catch {
            purchaseState = .failed
            localizedError = error.localizedDescription
        }
    }

    private func listenForTransactions() {
        updatesTask?.cancel()
        guard testingEntitlementOverride == nil,
              !processInfo.arguments.contains("-UITestingResetData") else { return }

        updatesTask = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                }
                await self.refreshEntitlements()
            }
        }
    }

    private func applyEntitlement(_ entitled: Bool) {
        isCloudSyncEntitled = entitled
        SubscriptionEntitlement.setEntitled(entitled, in: defaults)
    }

    private func resolvedTestingEntitlement() -> Bool? {
        if let testingEntitlementOverride {
            return testingEntitlementOverride
        }
        if processInfo.arguments.contains(SubscriptionEntitlement.uiTestingEntitledArgument) {
            return true
        }
        if processInfo.arguments.contains("-UITestingResetData") {
            return false
        }
        return nil
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: LocalizedError {
        case productUnavailable
        case failedVerification

        var errorDescription: String? {
            switch self {
            case .productUnavailable:
                "暂时无法获取订阅产品，请稍后重试。"
            case .failedVerification:
                "购买验证失败，请稍后重试。"
            }
        }
    }
}
