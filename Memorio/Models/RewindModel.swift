//
//  RewindModel.swift
//  Memorio
//
//  Created by Michal Dobes on 27/08/2020.
//

import Foundation
import CoreData

struct RewindModel {
    private var memories = [CalendarMemory]()
    private let today = Date()
    private let calendar = Calendar.current
    
    public mutating func fetchFromCoreData() {
        let context = PersistentStore.shared.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Memory.fetchRequest()
            
        do {
            let fetchedMemories = try context.fetch(fetchRequest) as? [Memory]

            memories = groupMemories(fetchedMemories ?? [])
        } catch {
            print(#function, "Fetch failed.")
        }
    }
    
    private func groupMemories(_ memories: [Memory]) -> [CalendarMemory] {
        var toReturn = [CalendarMemory]()
        for memory in memories {
            if let existingIndex = toReturn.firstIndex(where: { (existingMemory) -> Bool in
                calendar.isDate(existingMemory.date, inSameDayAs: memory.date ?? Date())
            }) {
                toReturn[existingIndex].memories.append(memory)
            } else {
                toReturn.append(CalendarMemory(date: memory.date ?? Date(), memories: [memory]))
            }
        }
        return toReturn
    }
    
    private func memoryForDate(component: Calendar.Component, value: Int) -> CalendarMemory? {
        let newDate = calendar.date(byAdding: component, value: value, to: today)
        if let memory = memories.first(where: { calendar.isDate($0.date, inSameDayAs: newDate!) }) {
            return memory
        }
        return nil
    }
    
    public var rewindAWeekAgo: CalendarMemory? {
        memoryForDate(component: .weekOfYear, value: -1)
    }
    
    public var rewindATwoWeekAgo: CalendarMemory? {
        memoryForDate(component: .weekOfYear, value: -2)
    }
    
    public var rewindAMonthAgo: CalendarMemory? {
        memoryForDate(component: .month, value: -1)
    }
    
    public var rewindATwoMonthsAgo: CalendarMemory? {
        memoryForDate(component: .month, value: -2)
    }
    
    public var rewindAThreeMonthsAgo: CalendarMemory? {
        memoryForDate(component: .month, value: -3)
    }
    
    public var rewindASixMonthsAgo: CalendarMemory? {
        memoryForDate(component: .month, value: -6)
    }
    
    public var rewindAYearAgo: CalendarMemory? {
        memoryForDate(component: .year, value: -1)
    }
    
    public var rewindATwoYearsAgo: CalendarMemory? {
        memoryForDate(component: .year, value: -1)
    }
    
    public var rewindA100DaysAgo: CalendarMemory? {
        memoryForDate(component: .day, value: -100)
    }
    
    public var rewindA123DaysAgo: CalendarMemory? {
        memoryForDate(component: .day, value: -123)
    }
    
    public var rewindA333DaysAgo: CalendarMemory? {
        memoryForDate(component: .day, value: -333)
    }
}

struct RewindMemory: Identifiable {
    var memory: CalendarMemory
    var rewind: String
    
    public var id = UUID()
}
