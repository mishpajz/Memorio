//
//  CalendarViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 08/08/2020.
//

import Foundation

class CalendarViewModel: ObservableObject {
    @Published private var model = CalendarModel()
    private var memoryModel = MemoryModel()
    
    @Published var presentingMemory = false
    
    @Published var selectedMemories = [Memory]()
    
    public var calendarYear: CalendarYear {
        model.calendarYear
    }
    
    public var currentYear: Int {
        model.currentYear
    }
    
    public var nextYear: Int? {
        model.nextYear
    }
    
    public var previousYear: Int {
        model.previousYear
    }
    
    public func setNextYear() {
        model.setNextYear()
    }
    
    public func setPreviousYear() {
        model.setPreviousYear()
    }
    
    @objc public func fetchFromCoreData() {
        model.fetchFromCoreData()
    }
    
    public func selectMemories(memories: [Memory]) {
        selectedMemories = memories
    }
    
    public func removeInDay() {
        for memory in selectedMemories {
            memoryModel.deleteMemory(memory)
        }
        PersistentStore.shared.save()
        fetchFromCoreData()
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFromCoreData), name: .newDataInCoreData, object: nil)
    }
}
