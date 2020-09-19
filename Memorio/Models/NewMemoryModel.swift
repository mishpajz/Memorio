//
//  NewMemoryModel.swift
//  Memorio
//
//  Created by Michal Dobes on 14/08/2020.
//

import Foundation
import CoreData
import Combine

public struct NewMemoryModel {
    
    public func createNewMemory(type: MemoryType, title: String?, content: String?, data: Data?) {
        saveIntoCoreData(date: Date(), type: type.rawValue, title: title, content: content, data: data)
    }
    
    private func saveIntoCoreData(date: Date, type: Int, title: String?, content: String?, data: Data?) {
        let context = PersistentStore.shared.persistentContainer.viewContext
        guard let memoryEntity = NSEntityDescription.entity(forEntityName: "Memory", in: context) else { return }
        
        let newMemory = NSManagedObject(entity: memoryEntity, insertInto: context)
        newMemory.setValue(date, forKey: "date")
        newMemory.setValue(type, forKey: "type")
        newMemory.setValue(title, forKey: "title")
        newMemory.setValue(content, forKey: "content")
        newMemory.setValue(data, forKey: "data")
        newMemory.setValue(UUID(), forKey: "id")
        
        PersistentStore.shared.save()
    }
}
