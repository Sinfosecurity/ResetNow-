//
//  StoreManager.swift
//  ResetNow
//
//  Handles In-App Purchases using StoreKit 2
//

import Foundation
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias Product = StoreKit.Product

public enum StoreError: Error {
    case failedVerification
}

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    @Published var isLoading = false
    
    // Product IDs
    // Note: These must match what's in App Store Connect / StoreKit Config file
    private let productIDs = [
        "com.resetnow.monthly",
        "com.resetnow.yearly"
    ]
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = newTransactionListenerTask()
    }
    
    deinit {
        updates?.cancel()
    }
    
    // MARK: - Core Logic
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            // Sort by price (Monthly < Yearly)
            products.sort { $0.price < $1.price } 
            
            // Check entitlements
            await updatePurchasedProducts()
        } catch {
            print("Failed to load products: \(error)")
        }
        isLoading = false
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function throws an error.
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updatePurchasedProducts()
            
            // Always finish a transaction.
            await transaction.finish()
            
        case .userCancelled, .pending:
            break
        default:
            break
        }
    }
    
    // Check if user has active subscription
    var hasPremiumAccess: Bool {
        return !purchasedProductIDs.isEmpty
    }
    
    // MARK: - Transaction Listener
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Deliver content to the user.
                    await self.updatePurchasedProducts()
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification; ignore it.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    // MARK: - Entitlements
    
    func updatePurchasedProducts() async {
        var purchased = Set<String>()
        
        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified.
                let transaction = try checkVerified(result)
                
                // Check if the subscription is still valid
                if let revocationDate = transaction.revocationDate {
                    // Revoked (refunded)
                    continue
                }
                
                if let expirationDate = transaction.expirationDate {
                    if expirationDate < Date() {
                        // Expired
                        continue
                    }
                }
                
                // If we got here, it's valid
                purchased.insert(transaction.productID)
                
            } catch {
                print("Entitlement verification failed")
            }
        }
        
        self.purchasedProductIDs = purchased
    }
    
    func restorePurchases() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    // MARK: - Helpers
    
    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
    // MARK: - Debug/Simulator Support
    func debugUnlock() {
        purchasedProductIDs.insert("com.resetnow.yearly")
    }
}
