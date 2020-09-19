//
//  PinGridViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import Foundation
import UIKit

class PinGridViewModel {
    private let generator = UISelectionFeedbackGenerator()
    
    public func hapticFeedback() {
        generator.selectionChanged()
    }
}

protocol GridPin {
    func appendToPin(number: Int)
    func removeFromPin()
}
