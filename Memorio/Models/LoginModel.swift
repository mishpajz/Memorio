//
//  LoginModel.swift
//  Memorio
//
//  Created by Michal Dobes on 24/08/2020.
//

import Foundation
import KeychainAccess

struct LoginModel {
    let keychain = Keychain(service: "MDobes.Memorio")
    
    public func isUsingAuth() -> Bool {
        if let data = try? keychain.getData("usingAuth") {
            let auth = try? JSONDecoder().decode(Bool.self, from: data)
            return auth ?? false
        }
        return false
    }
    
    public func doNotUseAuth() {
        if let data = try? JSONEncoder().encode(false) {
            try? keychain.set(data, key: "usingAuth")
        }
    }
    
    public func useAuth(with pin: String) {
        if let useData = try? JSONEncoder().encode(true) {
            try? keychain.set(useData, key: "usingAuth")
            try? keychain.set(pin, key: "psswrd")
        }
    }
    
    public func checkForMatch(in pin: String) -> Bool {
        if let password = try? keychain.get("psswrd") {
            return pin == password
        }
        return !isUsingAuth()
    }
}
