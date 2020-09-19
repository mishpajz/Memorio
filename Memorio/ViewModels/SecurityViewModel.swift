//
//  SecurityViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import Foundation
import LocalAuthentication
import UIKit

class SecurityViewModel: ObservableObject, GridPin {
    private var context = LAContext()
    private var model: LoginModel
    
    @Published var usingAuth: Bool {
        didSet {
            if usingAuth {
                settingPin = true
            } else {
                model.doNotUseAuth()
            }
        }
    }
    @Published var faceIDInUse: Bool {
        didSet {
            if faceIDInUse, !canUseFaceID {
                faceIDInUse = false
                cantUseFaceIdAlert = true
            } else {
                UserDefaults.standard.set(faceIDInUse, forKey: "useFaceID")
            }
        }
    }
    @Published var settingPin: Bool = false
    @Published var cantUseFaceIdAlert = false
    
    @Published var originalPin = "" {
        didSet {
            checkForMatch()
        }
    }
    @Published var controlPin = "" {
        didSet {
            checkForMatch()
        }
    }
    @Published var failedPinControl = false {
        didSet {
            if failedPinControl {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.failedPinControl = false
                }
            }
        }
    }
    
    public var currentPinSelection: CurrentPinSelection = .original
    
    private func checkForMatch() {
        switch currentPinSelection {
        case .original:
            if originalPin.count == 4 {
                currentPinSelection = .control
            }
        case .control:
            if controlPin.count == 4 {
                if compareOriginalToControl() {
                    model.useAuth(with: originalPin)
                    currentPinSelection = .original
                    settingPin = false
                } else {
                    failedPinControl = true
                    controlPin = ""
                    hapticFeedbackOnMatch(success: false)
                }
            }
        }
    }
    
    public func compareOriginalToControl() -> Bool {
        return originalPin == controlPin
    }
    
    public func appendToPin(number: Int) {
        if !failedPinControl {
            switch currentPinSelection {
            case .original:
                if originalPin.count < 5 {
                    originalPin.append("\(number)")
                }
            case .control:
                if controlPin.count < 5 {
                    controlPin.append("\(number)")
                }
            }
        }
    }
    
    public func removeFromPin() {
        if !failedPinControl {
            switch currentPinSelection {
            case .original:
                if originalPin.count > 0 {
                    originalPin.removeLast()
                }
            case .control:
                if controlPin.count > 0 {
                    controlPin.removeLast()
                } else if controlPin.count == 0 {
                    currentPinSelection = .original
                }
            }
        }
    }
    
    public var faceidAvailable: Bool {
        return context.biometryType == .faceID
    }
    
    public var canUseFaceID: Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public var currentPin: String {
        switch currentPinSelection {
        case .original:
            return originalPin
        case .control:
            return controlPin
        }
    }
    
    public func goBack() {
        switch currentPinSelection {
        case .control:
            controlPin = ""
            currentPinSelection = .original
        case .original:
            originalPin = ""
            controlPin = ""
            settingPin = false
            usingAuth = false
        }
    }
    
    public func setPin() {
        originalPin = ""
        controlPin = ""
        settingPin = true
        currentPinSelection = .original
    }
    
    private func hapticFeedbackOnMatch(success: Bool) {
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
        } else {
            generator.notificationOccurred(.error)
        }
    }
    
    public enum CurrentPinSelection {
        case original
        case control
    }
    
    init() {
        model = LoginModel()
        usingAuth = model.isUsingAuth()
        faceIDInUse = UserDefaults.standard.bool(forKey: "useFaceID")
    }
}
