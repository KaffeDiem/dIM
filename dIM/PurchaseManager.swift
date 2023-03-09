//
//  PurchaseManager.swift
//  dIM
//
//  Created by Kasper Munch on 03/03/2023.
//

import Foundation
import StoreKit
import Combine

/// The purchase manager handles fetching
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    enum ProductIds: String, CaseIterable {
        case stickers = "dim_sticker_unlock"
    }
    
    /// Determine if the purchase manager is still loading purchased products.
    @Published private(set) var isProductsLoaded = false
    /// All purchased product ids as strings.
    @Published private(set) var purchasedProductIds = Set<ProductIds>()
    /// List of all available products.
    @Published private(set) var availableProducts: [Product] = []
    /// List of all purchased products.
    @Published private(set) var purchasedProducts: [Product] = []
    /// Available products which has not yet been purcahsed
    @Published private(set) var availableProductsNotPurchased: [Product] = []
    
    private var updates: Task<Void, Never>? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        updates = oberserveTransactionUpdates()
        
        $availableProducts.combineLatest($purchasedProducts)
            .sink { [weak self] available, purchased in
                var availableForPurchase: [Product] = []
                for availableProduct in available {
                    if !purchased.contains(availableProduct) {
                        availableForPurchase.append(availableProduct)
                    }
                }
                self?.availableProductsNotPurchased = availableForPurchase
            }.store(in: &cancellables)
    }
    
    deinit {
        updates?.cancel()
    }
    
    @MainActor
    func loadProducts() async throws {
        // Do not load products if it has been done already
        guard !self.isProductsLoaded else { return }
        self.availableProducts = try await Product.products(for: ProductIds.allCases.map { $0.rawValue })
        await updatePurchasedProducts()
        self.isProductsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let purchaseResult = try await product.purchase()
        
        switch purchaseResult {
        case .success(.verified(let transaction)): ()
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified(let _, let error)):
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
        await updatePurchasedProducts()
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            guard let supportedProductId = ProductIds(rawValue: transaction.productID) else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIds.insert(supportedProductId)
            } else {
                self.purchasedProductIds.remove(supportedProductId)
            }
        }
        do {
            self.purchasedProducts = try await Product.products(for: purchasedProductIds.map { $0.rawValue })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Listen for purchases on other devices.
    private func oberserveTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            guard let self else { return }
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}
