//
//  TabBarViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 13/09/2020.
//

import Foundation
import StoreKit

class TabBarViewModel: ObservableObject {
    private let subscriptionModel = PlusModel()
    private var model = TabBarModel()
    
    public func isAvailable() -> Bool {
        if subscriptionModel.isPlus() {
            return true
        } else {
            if model.memoriesThisWeek.count < 2 {
                return true
            }
        }
        return false
    }
    
    public func askForReview() {
        let defaults = UserDefaults.standard
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if !defaults.bool(forKey: "didAlreadyRate") {
                var actionCount = defaults.integer(forKey: "rateActions")
                
                actionCount += 1
                
                defaults.set(actionCount, forKey: "rateActions")
                
                if actionCount >= Constants.actionsNeededForReview {
                    defaults.set(true, forKey: "didAlreadyRate")
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    @objc func fetchFromCoreData() {
        model.fetchFromCoreData()
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromCoreData), name: .newDataInCoreData, object: nil)
    }
}
