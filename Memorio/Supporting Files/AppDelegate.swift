//
//  AppDelegate.swift
//  Memorio
//
//  Created by Michal Dobes on 06/09/2020.
//

import Foundation
import UIKit
import SwiftyStoreKit
import Intents

class AppDelegate: UIResponder, UIApplicationDelegate {
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
                    
                    self.subscriptionModel.validateSubscriptions()
                case .failed, .purchasing, .deferred:
                    if purchase.productId == MemorioPlusProducts.plusLifetime {
                        self.subscriptionModel.setBought(with: MemorioPlusProducts.plusLifetime, value: false)
                    }
                    self.subscriptionModel.validateSubscriptions()
                @unknown default:
                    break
                }
            }
        }
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            if product.productIdentifier == MemorioPlusProducts.plusLifetime {
                self.subscriptionModel.setBought(with: MemorioPlusProducts.plusLifetime, value: true)
            }
            self.subscriptionModel.validateSubscriptions()
            return true
        }
        return true
    }
}
