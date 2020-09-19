//
//  AppDelegate.swift
//  Memorio
//
//  Created by Michal Dobes on 06/09/2020.
//

import Foundation
import UIKit
import SwiftyStoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let subscriptionModel = PlusModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    if purchase.productId == MemorioPlusProducts.plusLifetime {
                        self.subscriptionModel.setBought(with: MemorioPlusProducts.plusLifetime, value: true)
                        NotificationCenter.default.post(name: .transactionFinished, object: nil)
                    }
                case .failed, .purchasing, .deferred:
                    if purchase.productId == MemorioPlusProducts.plusLifetime {
                        self.subscriptionModel.setBought(with: MemorioPlusProducts.plusLifetime, value: false)
                    }
                @unknown default:
                    break
                }
            }
        }
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            if product.productIdentifier == MemorioPlusProducts.plusLifetime {
                self.subscriptionModel.setBought(with: MemorioPlusProducts.plusLifetime, value: true)
            }
            return true
        }
        return true
    }
}
