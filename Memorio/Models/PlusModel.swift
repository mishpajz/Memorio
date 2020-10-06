//
//  PlusModel.swift
//  Memorio
//
//  Created by Michal Dobes on 03/09/2020.
//

import Foundation
import KeychainAccess
import StoreKit
import SwiftyStoreKit

struct PlusModel {
    let keychain = Keychain(service: "MDobes.Memorio.IAPs")
    
    public func getBought(with identifier: String) -> Bool {
        if let data = try? keychain.getData(identifier) {
            let auth = try? JSONDecoder().decode(Bool.self, from: data)
            return auth ?? false
        }
        return false
    }
    
    public func setBought(with identifier: String, value: Bool) {
        if let data = try? JSONEncoder().encode(value) {
            try? keychain.set(data, key: identifier)
        }
    }
    
    public func purchase(product: SKProduct) {
        if SwiftyStoreKit.canMakePayments {
            SwiftyStoreKit.purchaseProduct(product, atomically: true) { result in
                switch result {
                case .success(purchase: let purchase):
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    if purchase.productId == MemorioPlusProducts.plusLifetime {
                        self.setBought(with: MemorioPlusProducts.plusLifetime, value: true)
                        NotificationCenter.default.post(name: .transactionFinished, object: nil)
                    }
                    
                    validateSubscriptions()
                    print("Purchase success")
                case .error(error: let error):
                    print(#function, "Purchase failed: \(error.localizedDescription)")
                    NotificationCenter.default.post(name: .transactionFinished, object: nil)
                }
            }
        }
    }
    
    public func isPlus() -> Bool {
        for product in MemorioPlusProducts.productIdentifiers {
            if getBought(with: product) {
                return true
            }
        }
        return false
    }
    
    public func validateSubscriptions() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(ofType: .autoRenewable, productIds: MemorioPlusProducts.subscriptionIdentifiers, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(expiryDate: _, items: let items):
                    if let product = items.first?.productId {
                        if product == MemorioPlusProducts.plusYearly {
                            self.setBought(with: MemorioPlusProducts.plusMonthly, value: false)
                        } else if product == MemorioPlusProducts.plusMonthly {
                            self.setBought(with: MemorioPlusProducts.plusYearly, value: false)
                        }
                        self.setBought(with: product, value: true)
                    }
                case .expired(expiryDate: _, items: let items):
                    if let product = items.first?.productId {
                        self.setBought(with: product, value: false)
                    }
                case .notPurchased:
                    for subscription in MemorioPlusProducts.subscriptionIdentifiers {
                        self.setBought(with: subscription, value: false)
                    }
                }
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
}

struct MemorioPlusProducts {
    
    static let plusLifetime = "MDobes.Memorio.Plus"
    static let plusMonthly = "MDobes.Memorio.monthly.Plus"
    static let plusYearly = "MDobes.Memorio.yearly.Plus"
    
    static let subscriptionIdentifiers: Set<String> = [plusMonthly, plusYearly]
    static let productIdentifiers: Set<String> = [plusLifetime, plusMonthly, plusYearly]
}
