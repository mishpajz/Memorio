//
//  CoreData.swift
//  Memorio
//
//  Created by Michal Dobes on 10/08/2020.
//

import Foundation
import CoreData

public class PersistentStore {
    
    public static let shared = PersistentStore()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemorioCoreData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
        NotificationCenter.default.post(name: .newDataInCoreData, object: nil)
    }
}
