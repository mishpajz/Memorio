//
//  TabBarModel.swift
//  Memorio
//
//  Created by Michal Dobes on 13/09/2020.
//

import Foundation
import CoreData

struct TabBarModel {
    public var memoriesThisWeek = [Memory]()
    private let calendar = Calendar.current
    
    public mutating func fetchFromCoreData() {
        let context = PersistentStore.shared.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Memory.fetchRequest()
            
        do {
            let fetchedMemories = try context.fetch(fetchRequest) as? [Memory]

            memoriesThisWeek = groupMemories(fetchedMemories ?? [])
        } catch {
            print(#function, "Fetch failed.")
        }
    }
    
    private func groupMemories(_ memories: [Memory]) -> [Memory] {
        var toReturn = [Memory]()
        for memory in memories {
            if let memoryDate = memory.date, calendar.isDate(memoryDate, equalTo: Date(), toGranularity: .weekOfYear) {
                toReturn.append(memory)
            }
        }
        return toReturn
    }
    
    init() {
        fetchFromCoreData()
    }
}
