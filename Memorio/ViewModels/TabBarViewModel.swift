//
//  TabBarViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 13/09/2020.
//

import Foundation
import StoreKit
import Intents

class TabBarViewModel: ObservableObject {
    private let subscriptionModel = PlusModel()
    private var model = TabBarModel()
    
    public func isAvailable() -> Bool {
        donateCreateIntent()
        if subscriptionModel.isPlus() {
            return true
        } else {
            if model.memoriesThisWeek.count < 2 {
                return true
            }
        }
        return false
    }
    
    public func donateCreateIntent() {
        let intent = CreateMemoryIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: nil)
    }
    
    public func askForReview() {
        let defaults = UserDefaults.standard
        
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if !defaults.bool(forKey: Constants.didAlreadyRate) {
                var actionCount = defaults.integer(forKey: Constants.rateActions)
                
                actionCount += 1
                
                defaults.set(actionCount, forKey: Constants.rateActions)
                
                if actionCount >= Constants.actionsNeededForReview {
                    defaults.set(true, forKey: Constants.didAlreadyRate)
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
