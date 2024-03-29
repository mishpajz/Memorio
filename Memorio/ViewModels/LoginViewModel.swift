//
//  LoginViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 24/08/2020.
//

import Foundation
import LocalAuthentication
import UIKit

class LoginViewModel: ObservableObject, GridPin {
    private var context: LAContext
    @Published private var model = LoginModel()
    
    @Published private(set) var enteredPin = ""
    
    @Published public var authenticated: Bool = false
    @Published public var failedLogin: Bool = false
    private var authenticatingUsingFaceId = false
    public var authenticationCancelledByUser = false
    
    private var biometricsAvailable: Bool {
        return context.biometryType != .none
    }
    
    public func usingAuthentication() -> Bool {
        model.isUsingAuth()
    }
    
    public func checkIfShouldRequireAuth() {
        if !usingAuthentication() {
            DispatchQueue.main.async {
                self.authenticated = true
                self.authenticationCancelledByUser = false
            }
        }
    }
    
    public func appendToPin(number: Int) {
        if enteredPin.count < 5, !failedLogin {
            enteredPin.append("\(number)")
        }
        checkForMatch()
    }
    
    public func removeFromPin() {
        if enteredPin.count > 0, !failedLogin {
            enteredPin.removeLast()
        }
        checkForMatch()
    }
    
    public func unAuthenticate() {
        if !authenticatingUsingFaceId {
            authenticated = false
        }
    }
    
    public func resetAuthentication() {
        if !authenticatingUsingFaceId {
            context = LAContext()
            context.localizedCancelTitle = "Enter passcode"
        }
    }
    
    @objc public func shouldLogIn() {
        resetAuthentication()
        unAuthenticate()
    }
    
    private func checkForMatch() {
        if enteredPin.count == 4 {
            if !authenticated {
                if model.checkForMatch(in: enteredPin) {
                    authenticated = true
                    authenticationCancelledByUser = false
                    hapticFeedbackOnMatch(success: true)
                } else {
                    failedLogin = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        self?.failedLogin = false
                    }
                    hapticFeedbackOnMatch(success: false)
                }
            }
            enteredPin = ""
        }
    }
    
    public func authUsingBiometrics() {
        if !authenticated, !authenticatingUsingFaceId {
            if canUseBiometrics(), usingAuthentication() {
                authenticatingUsingFaceId = true
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate into Memorio") { (success, error) in
                    if let error = error {
                        print(#function, error)
                    }
                    DispatchQueue.main.async {
                        if !self.authenticated {
                            self.authenticated = success
                            if success {
                                self.authenticationCancelledByUser = false
                            }
                        }
                        self.authenticatingUsingFaceId = false
                        if success {
                            self.context.invalidate()
                        }
                        
                        if let error = error {
                            switch error {
                            case LAError.userCancel:
                                self.authenticationCancelledByUser = true
                            default: break
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func canUseBiometrics() -> Bool {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil), UserDefaults.standard.bool(forKey: "useFaceID") {
            return true
        }
        return false
    }
    
    private func hapticFeedbackOnMatch(success: Bool) {
        let generator = UINotificationFeedbackGenerator()
        if success {
            generator.notificationOccurred(.success)
        } else {
            generator.notificationOccurred(.error)
        }
    }
    
    init() {
        context = LAContext()
        context.localizedCancelTitle = "Enter passcode"
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldLogIn), name: .shouldLogIn, object: nil)
    }
}
