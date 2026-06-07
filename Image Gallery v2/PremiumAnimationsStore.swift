//
//  PremiumAnimationsStore.swift
//  Image Gallery v2
//

import Foundation
import OSLog
import StoreKit

@MainActor
final class PremiumAnimationsStore {
    static let shared = PremiumAnimationsStore()
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ImageKeeper", category: "PremiumAnimationsStore")

    enum PurchaseOutcome {
        case success
        case cancelled
        case pending
        case interruptedNeedsRetry
        case failed(String)
    }

    let productID = "com.soulfulmachine.imagegallery.premiumanimations"

    private(set) var premiumProduct: Product?
    private(set) var isPremiumUnlocked = false {
        didSet {
            if oldValue != isPremiumUnlocked {
                NotificationCenter.default.post(name: .premiumAnimationsStatusDidChange, object: nil)
            }
        }
    }

    private var transactionUpdatesTask: Task<Void, Never>?
    private var hasStarted = false

    private init() {}

    private static func debugPrint(_ message: String) {
        print("[PremiumAnimationsStore] \(message)")
    }

    var premiumPriceDisplay: String? {
        premiumProduct?.displayPrice
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        Self.logger.log("Starting premium animations store. Product ID: \(self.productID, privacy: .public)")
        Self.debugPrint("Starting premium animations store. Product ID: \(productID)")

        transactionUpdatesTask = Task {
            for await verificationResult in Transaction.updates {
                Self.logger.log("Received transaction update from StoreKit.")
                Self.debugPrint("Received transaction update from StoreKit.")
                _ = try? Self.checkVerified(verificationResult)
                await refreshEntitlements()
            }
        }

        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    func loadProduct() async {
        do {
            premiumProduct = try await Product.products(for: [productID]).first
            if let premiumProduct {
                Self.logger.log("Loaded premium product: id=\(premiumProduct.id, privacy: .public), price=\(premiumProduct.displayPrice, privacy: .public)")
                Self.debugPrint("Loaded premium product: id=\(premiumProduct.id), price=\(premiumProduct.displayPrice)")
            } else {
                Self.logger.error("Premium product list returned no matching product for id \(self.productID, privacy: .public)")
                Self.debugPrint("Premium product list returned no matching product for id \(productID)")
            }
        } catch {
            premiumProduct = nil
            Self.logger.error("Failed to load premium product \(self.productID, privacy: .public): \(error.localizedDescription, privacy: .public)")
            Self.debugPrint("Failed to load premium product \(productID): \(error.localizedDescription)")
        }
    }

    func refreshEntitlements() async {
        var unlocked = false

        for await verificationResult in Transaction.currentEntitlements {
            guard let transaction = try? Self.checkVerified(verificationResult) else { continue }
            if transaction.productID == productID && transaction.revocationDate == nil {
                unlocked = true
                break
            }
        }

        isPremiumUnlocked = unlocked
        Self.logger.log("Entitlement refresh complete. Premium unlocked = \(self.isPremiumUnlocked, privacy: .public)")
        Self.debugPrint("Entitlement refresh complete. Premium unlocked = \(isPremiumUnlocked)")
    }

    func purchasePremiumAnimations() async -> PurchaseOutcome {
        start()
        Self.logger.log("Beginning premium purchase flow.")
        Self.debugPrint("Beginning premium purchase flow.")

        if premiumProduct == nil {
            Self.logger.log("No cached premium product. Loading product before purchase.")
            Self.debugPrint("No cached premium product. Loading product before purchase.")
            await loadProduct()
        }

        guard let premiumProduct else {
            Self.logger.error("Purchase aborted because premium product is unavailable.")
            Self.debugPrint("Purchase aborted because premium product is unavailable.")
            return .failed("Premium purchase is currently unavailable.")
        }

        do {
            let result = try await premiumProduct.purchase()

            switch result {
            case .success(let verificationResult):
                Self.logger.log("StoreKit returned purchase success. Verifying transaction.")
                Self.debugPrint("StoreKit returned purchase success. Verifying transaction.")
                let transaction = try Self.checkVerified(verificationResult)
                await transaction.finish()
                Self.logger.log("Transaction finished for product \(transaction.productID, privacy: .public). Refreshing entitlements.")
                Self.debugPrint("Transaction finished for product \(transaction.productID). Refreshing entitlements.")
                await refreshEntitlements()
                if isPremiumUnlocked {
                    Self.logger.log("Premium entitlement became active after purchase.")
                    Self.debugPrint("Premium entitlement became active after purchase.")
                    return .success
                } else {
                    Self.logger.error("Purchase completed but premium entitlement is still missing after refresh.")
                    Self.debugPrint("Purchase completed but premium entitlement is still missing after refresh.")
                    return .failed("Purchase completed, but the premium unlock is still missing. Try Restore Purchases.")
                }
            case .userCancelled:
                Self.logger.log("User cancelled premium purchase.")
                Self.debugPrint("User cancelled premium purchase.")
                await refreshEntitlements()
                return .cancelled
            case .pending:
                Self.logger.log("Premium purchase is pending.")
                Self.debugPrint("Premium purchase is pending.")
                return .pending
            @unknown default:
                Self.logger.error("Purchase returned an unknown result.")
                Self.debugPrint("Purchase returned an unknown result.")
                return .failed("Purchase could not be completed.")
            }
        } catch {
            Self.logger.error("Premium purchase threw error: \(error.localizedDescription, privacy: .public)")
            Self.debugPrint("Premium purchase threw error: \(error.localizedDescription)")
            return .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async -> PurchaseOutcome {
        start()
        Self.logger.log("Starting restore purchases flow.")
        Self.debugPrint("Starting restore purchases flow.")

        do {
            try await AppStore.sync()
            Self.logger.log("AppStore.sync() completed. Refreshing entitlements.")
            Self.debugPrint("AppStore.sync() completed. Refreshing entitlements.")
            await refreshEntitlements()
            if isPremiumUnlocked {
                Self.logger.log("Restore purchases succeeded and premium entitlement is active.")
                Self.debugPrint("Restore purchases succeeded and premium entitlement is active.")
                return .success
            } else {
                Self.logger.error("Restore purchases completed but no premium entitlement was found.")
                Self.debugPrint("Restore purchases completed but no premium entitlement was found.")
                return .failed("No premium purchases were found to restore.")
            }
        } catch {
            Self.logger.error("Restore purchases failed: \(error.localizedDescription, privacy: .public)")
            Self.debugPrint("Restore purchases failed: \(error.localizedDescription)")
            return .failed(error.localizedDescription)
        }
    }

    func isStyleUnlocked(_ style: ImageGalleryModel.GachaAnimationStyle) -> Bool {
        !style.requiresPremiumUnlock || isPremiumUnlocked
    }

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            logger.error("Encountered unverified StoreKit transaction or entitlement.")
            debugPrint("Encountered unverified StoreKit transaction or entitlement.")
            throw StoreError.failedVerification
        }
    }

    enum StoreError: Error {
        case failedVerification
    }
}
