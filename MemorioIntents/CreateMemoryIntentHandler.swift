//
//  CreateMemoryIntentHandler.swift
//  Memorio
//
//  Created by Michal Dobes on 09.06.2021.
//

import Foundation
import Intents

class CreateMemoryIntentHandler: NSObject, CreateMemoryIntentHandling {
    func handle(intent: CreateMemoryIntent, completion: @escaping (CreateMemoryIntentResponse) -> Void) {
        completion(CreateMemoryIntentResponse(code: .continueInApp, userActivity: NSUserActivity(activityType: "CreateMemoryIntent")))
    }
}
