

import Foundation
import StoreKit
import Combine

@MainActor
final class InAppPurchaseViewModel: ObservableObject {

    @Published var product: Product?
    @Published var isLoading = false
    @Published var isPurchased: Bool = UserDefaults.standard.bool(forKey: AppDefaults.DefaultsKey.isPro)
    @Published var presentErrorAlert = false
    @Published var errorMessage: String = ""

    private var transactionListenerTask: Task<Void, Never>?

    init() {
        transactionListenerTask = listenForTransactionUpdates()
    }

    deinit {
        transactionListenerTask?.cancel()
    }


    func fetchProduct() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [AppDefaults.lifetimeProductId])
            guard let product = products.first else {
                print("Wrenchlog: product \(AppDefaults.lifetimeProductId) was not found — check App Store Connect / StoreKit config")
                return
            }
            self.product = product
            AppDefaults.lifetimePrice = product.displayPrice
            await refreshPurchaseState()
        } catch {
            print("Wrenchlog: failed to load product — \(error)")
            errorMessage = "Could not load the store. Check your connection and try again."
            presentErrorAlert = true
        }
    }


    func purchase() async {
        guard let product else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    setPurchased(true)
                case .unverified(_, let error):
                    print("Wrenchlog: unverified transaction — \(error)")
                    errorMessage = "We couldn't verify this purchase. Please try again."
                    presentErrorAlert = true
                }
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Wrenchlog: purchase failed — \(error)")
            errorMessage = "Purchase failed. Please try again."
            presentErrorAlert = true
        }
    }


    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await refreshPurchaseState()
        } catch {
            print("Wrenchlog: restore failed — \(error)")
            errorMessage = "Could not restore purchases. Please try again."
            presentErrorAlert = true
        }
    }


    func refreshPurchaseState() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == AppDefaults.lifetimeProductId, transaction.revocationDate == nil {
                setPurchased(true)
                return
            }
        }
        setPurchased(false)
    }

    private func setPurchased(_ value: Bool) {
        isPurchased = value
        UserDefaults.standard.set(value, forKey: AppDefaults.DefaultsKey.isPro)
    }


    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await transaction.finish()
                await self?.refreshPurchaseState()
            }
        }
    }
}
