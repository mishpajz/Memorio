//
//  RewindViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 27/08/2020.
//

import Foundation
import SwiftUI

class RewindViewModel: ObservableObject {
    
    private var model: RewindModel
    
    @Published var presentingMemory = false
    @Published var selectedMemories = [Memory]()
    
    public var isRewindAvailable: Bool {
        !rewinds.isEmpty
    }
    
    @Published var rewinds = [RewindMemory]()
    
    public func selectRewind(rewind: RewindMemory) {
        selectedMemories = rewind.memory.memories
    }
    
    public func refetchFromCoreData() {
        model.fetchFromCoreData()
        var fetchedRewinds = [RewindMemory]()
        
        if let fetchedMemory = model.rewindAWeekAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A week ago"))
        }
        
        if let fetchedMemory = model.rewindATwoWeekAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A two weeks ago"))
        }
        
        if let fetchedMemory = model.rewindAMonthAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A month ago"))
        }
        
        if let fetchedMemory = model.rewindATwoMonthsAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A two months ago"))
        }
        
        if let fetchedMemory = model.rewindAThreeMonthsAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A three months ago"))
        }
        
        if let fetchedMemory = model.rewindASixMonthsAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A six months ago"))
        }
        
        if let fetchedMemory = model.rewindAYearAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A year ago"))
        }
        
        if let fetchedMemory = model.rewindATwoYearsAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A two years ago"))
        }
        
        if let fetchedMemory = model.rewindA100DaysAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A 100 days ago"))
        }
        
        if let fetchedMemory = model.rewindA123DaysAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A 123 days ago"))
        }
        
        if let fetchedMemory = model.rewindA333DaysAgo {
            fetchedRewinds.append(RewindMemory(memory: fetchedMemory, rewind: "A 333 days ago"))
        }
        
        rewinds = fetchedRewinds
    }
    
    init() {
        model = RewindModel()
        model.fetchFromCoreData()
        refetchFromCoreData()
    }
}
