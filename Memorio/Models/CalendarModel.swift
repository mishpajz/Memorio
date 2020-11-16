//
//  CalendarModel.swift
//  Memorio
//
//  Created by Michal Dobes on 08/08/2020.
//

import Foundation
import CoreData
import Combine

struct CalendarModel {
    
    // MARK: - Properties
    // Helper properties and constants
    private var calendar = Calendar.current
    private let now = Date()
    private var dateComponents: DateComponents {
        DateComponents(calendar: calendar, year: currentYear)
    }
    private let minYearCap = 3
    
    // Main properties
    public var previousYear: Int {
        currentYear - 1
    }
    private(set) var currentYear: Int = 2020
    public var nextYear: Int? {
        guard calendar.component(.year, from: now) != currentYear else { return nil }
        return currentYear + 1
    }
    public var calendarYear: CalendarYear {
        var year = CalendarYear(months: [])
        monthloop: for (i, month) in months.enumerated() {
            year.months.insert(CalendarMonth(weeks: [], id: month), at: i)
            for (j, week) in weeks(for: month).enumerated() {
                year.months[i].weeks.insert(CalendarWeek(days: [], id: week), at: j)
                for (k, weekday) in days(for: week, in: month).enumerated() {
                    let dayAndId = day(weekday: weekday, in: week, in: month)
                    var memoriesOfDay = [Memory]()
                    if let currentDate = calendar.date(from: DateComponents(calendar: calendar, year: currentYear, month: month, weekday: weekday, weekOfMonth: week)) {
                        for memory in memories {
                            if calendar.isDate(memory.date , inSameDayAs: currentDate) {
                                memoriesOfDay = memory.memories
                                break
                            }
                        }
                        year.months[i].weeks[j].days.insert(CalendarDay(day: dayAndId.0, weekday: weekday, id: dayAndId.1, memories: memoriesOfDay), at: k)
                        if calendar.isDate(now, inSameDayAs: currentDate) {
                            break monthloop
                        }
                    }
                }
            }
        }
        return year
    }
    private var memories = [CalendarMemory]()
    
    // MARK: - Methods
    public mutating func setNextYear() {
        if let nextYear = nextYear {
            currentYear = nextYear
        }
    }
    
    public mutating func setPreviousYear() {
        let yearNow = calendar.component(.year, from: now)
        if (yearNow - previousYear) <= minYearCap {
            currentYear = previousYear
        }
    }

    // MARK: - Helper methods and vars
    // for calculating calendar objects
    private var months: Range<Int> {
        guard let yearDate = calendar.date(from: dateComponents) else { return 0..<0 }
        guard let range = calendar.range(of: .month, in: .year, for: yearDate) else { return 0..<0 }
        return range
    }
    
    private func weeks(for month: Int) -> Range<Int> {
        var newDateComponents = dateComponents
        newDateComponents.month = month
        guard let monthDate = calendar.date(from: newDateComponents) else { return 0..<0 }
        guard let range = calendar.range(of: .weekOfMonth, in: .month, for: monthDate) else { return 0..<0 }
        return range
    }
    
    private func days(for week: Int, in month: Int) -> [Int] {
        let numberOfWeeks = weeks(for: month)
        
        var newDateComponents = dateComponents
        newDateComponents.month = month
        guard let monthDate = calendar.date(from: newDateComponents) else { return [] }
        
        let firstDayOfWeekForCalendar = calendar.firstWeekday
        let daysForSundayWeek = [1, 2, 3, 4, 5, 6, 7]
        let daysForMondayWeek = [2, 3, 4, 5, 6, 7, 1]
        
        let startDay = calendar.component(.weekday, from: monthDate)
        
        if week == numberOfWeeks.first {
            
            if firstDayOfWeekForCalendar == 2 {
                guard let indexOfFirstDay = daysForMondayWeek.firstIndex(of: startDay) else { return [] }
                if indexOfFirstDay > 0 {
                    var editedDays = daysForMondayWeek
                    editedDays.removeFirst(indexOfFirstDay)
                    return editedDays
                } else {
                    return daysForMondayWeek
                }
            } else {
                guard let indexOfFirstDay = daysForSundayWeek.firstIndex(of: startDay) else { return [] }
                if indexOfFirstDay > 0 {
                    var editedDays = daysForSundayWeek
                    editedDays.removeFirst(indexOfFirstDay)
                    return editedDays
                } else {
                    return daysForSundayWeek
                }
            }
        }
        
        if week == numberOfWeeks.last {
            var addDateComponents = DateComponents()
            addDateComponents.month = 1
            addDateComponents.day = -1
            guard let endDate = calendar.date(byAdding: addDateComponents, to: monthDate) else { return [] }
            
            let endDay = calendar.component(.weekday, from: endDate)
            
            if firstDayOfWeekForCalendar == 2 {
                guard let indexOfLastDay = daysForMondayWeek.firstIndex(of: endDay) else { return [] }
                let daysToRemove = 6 - indexOfLastDay
                var editedDays = daysForMondayWeek
                editedDays.removeLast(daysToRemove)
                return editedDays
            } else {
                guard let indexOfLastDay = daysForSundayWeek.firstIndex(of: endDay) else { return [] }
                let daysToRemove = 6 - indexOfLastDay
                var editedDays = daysForSundayWeek
                editedDays.removeLast(daysToRemove)
                return editedDays
            }
        }

        if firstDayOfWeekForCalendar == 2 {
            return daysForMondayWeek
        }
        return daysForSundayWeek
    }
    
    private func day(weekday: Int, in week: Int, in month: Int) -> (Int, Int) {
        var newDateComponents = dateComponents
        newDateComponents.month = month
        newDateComponents.weekOfMonth = week
        newDateComponents.weekday = weekday
        guard let monthDate = calendar.date(from: newDateComponents) else { return (0, 0) }
        guard let yearDate = calendar.date(from: dateComponents) else { return (0, 0) }
        guard let days = calendar.dateComponents([.day], from: yearDate, to: monthDate).day else { return (0, 0) }
        return (calendar.component(.day, from: monthDate), days + 1)
    }
    
    public mutating func fetchFromCoreData() {
        let context = PersistentStore.shared.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Memory.fetchRequest()
        
        var memoriesFromCoreData = [CalendarMemory]()
            
        do {
            let fetchedMemories = try context.fetch(fetchRequest) as? [Memory]

            memoriesFromCoreData = groupMemories(fetchedMemories ?? [])
        } catch {
            print(#function, "Fetch failed.")
        }
        memories = memoriesFromCoreData
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
    
    // MARK: - Initialization
    init() {
        self.currentYear = calendar.component(.year, from: now)
        fetchFromCoreData()
        print(calendar.firstWeekday)
    }
}


// MARK: - Calendar objects
struct CalendarYear {
    var months: [CalendarMonth]
}

struct CalendarMonth: Identifiable {
    var weeks: [CalendarWeek]
    var id: Int
}

struct CalendarWeek: Identifiable {
    var days: [CalendarDay]
    var id: Int
}

struct CalendarDay: Identifiable {
    var day: Int
    var weekday: Int
    var id: Int
    var memories: [Memory]
    
}

struct CalendarMemory {
    var date: Date
    var memories: [Memory]
}
