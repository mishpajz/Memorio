//
//  PlusViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 30/08/2020.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import Combine
import SwiftUI

class PlusViewModel: ObservableObject {
    
    @Published public var products: Set<SKProduct>
    @Published public var loading: Bool = false
    
    public let subscriptionModel = PlusModel()
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    
    public func price(for id: String) -> String {
        guard let product = products.first(where: { $0.productIdentifier == id }) else { return "?" }
        let priceFormatter = NumberFormatter()
        priceFormatter.numberStyle = .currency
        return product.localizedPrice ?? "?"
    }
    
    public func purchase(id: String) {
        guard let product = products.first(where: { $0.productIdentifier == id }) else { return }
        loading = true
        subscriptionModel.purchase(product: product)
    }
    
    public func isPurchased(id: String) -> Bool {
        return subscriptionModel.getBought(with: id)
    }
    
    public func subscribing() -> Bool {
        for subscription in MemorioPlusProducts.subscriptionIdentifiers {
            if subscriptionModel.getBought(with: subscription) {
                return true
            }
        }
        return false
    }
    
    public func restore() {
        loading = true
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
            NotificationCenter.default.post(name: .transactionFinished, object: nil)
        }
    }
    
    public func validateSubscriptions() {
        subscriptionModel.validateSubscriptions()
    }
    
    public func hapticFeedback() {
        feedbackGenerator.notificationOccurred(.success)
    }
    
    @objc func transactionFinished() {
        loading = false
    }
    
    init() {
        var fetchedProducts: Set<SKProduct> = []
        self.products = fetchedProducts
        SwiftyStoreKit.retrieveProductsInfo(MemorioPlusProducts.productIdentifiers) { result in
            fetchedProducts = result.retrievedProducts
            for invalidProduct in result.invalidProductIDs {
                print(#function, "Invalid product: \(invalidProduct)")
            }
            if fetchedProducts.isEmpty && result.invalidProductIDs.isEmpty {
                print(#function, "Error: \(result.error?.localizedDescription ?? "unknown error")")
            }
            self.products = fetchedProducts
        }
        NotificationCenter.default.addObserver(self, selector: #selector(transactionFinished), name: .transactionFinished, object: nil)
    }
}
