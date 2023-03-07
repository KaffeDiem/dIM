//
//  PurchaseManager.swift
//  dIM
//
//  Created by Kasper Munch on 03/03/2023.
//

import Foundation
import StoreKit

/// The purchase manager handles fetching
class PurchaseManager: ObservableObject {
    enum ProductIds: String, CaseIterable {
        case stickers = "dim_sticker_unlock"
    }
    
    /// Set to true once the purchase manager has finished loading and will
    /// enable the user to send stickers to contacts.
    @Published private(set) var isStickersUnlocked = false
    /// Determine if the purchase manager is still loading purchased products.
    @Published private(set) var isProductsLoaded = false
    /// All purchased product ids as strings.
    @Published private(set) var purchasedProductIds = Set<ProductIds>()
    /// List of all available products.
    @Published private(set) var availableProducts: [Product] = []
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = oberserveTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    @MainActor
    func loadProducts() async throws {
        // Do not load products if it has been done already
        guard !self.isProductsLoaded else { return }
        self.availableProducts = try await Product.products(for: ProductIds.allCases.map { $0.rawValue })
        self.isProductsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult {
        case .success(.verified(let transaction)): ()
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified(let transaction, let error)):
            print(error.localizedDescription)
            break
        case .pending: ()
            break
        case .userCancelled: ()
            break
        default:
            break
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            guard let supportedProductId = ProductIds(rawValue: transaction.productID) else {
                #warning("Figure out what to do here")
                fatalError("Received a purchased product with unknown product id.")
            }
            if transaction.revocationDate == nil {
                self.purchasedProductIds.insert(supportedProductId)
            } else {
                self.purchasedProductIds.remove(supportedProductId)
            }
        }
    }
    
    /// Listen for purchases on other devices.
    private func oberserveTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            guard let self else { return }
            for await _ in Transaction.updates {
                // TODO: Work on the verification result directly here - no reason to fetch it again
                await self.updatePurchasedProducts()
            }
        }
    }
}
