//
//  TabBarViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 13/09/2020.
//

import Foundation

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
    
    @objc func fetchFromCoreData() {
        model.fetchFromCoreData()
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromCoreData), name: .newDataInCoreData, object: nil)
    }
}
