//
//  IconViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 11/09/2020.
//

import Foundation
import UIKit

class IconViewModel: ObservableObject {
    private let subscriptionModel = PlusModel()
    
    public func setNewIcon(with id: String?) {
        UIApplication.shared.setAlternateIconName(id) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func isPlus() -> Bool {
        subscriptionModel.isPlus()
    }
}
