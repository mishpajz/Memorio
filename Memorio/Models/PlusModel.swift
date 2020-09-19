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
                    print("Purchase success")
                case .error(error: let error):
                    print(#function, "Purchase failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func isPlus() -> Bool {
        if getBought(with: MemorioPlusProducts.plusLifetime) {
            return true
        }
        return false
    }
}

struct MemorioPlusProducts {
    
    static let plusLifetime = "MDobes.Memorio.Plus"
    
    static let productIdentifiers: Set<String> = [plusLifetime]
}
