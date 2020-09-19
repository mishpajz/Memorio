//
//  MemoryModel.swift
//  Memorio
//
//  Created by Michal Dobes on 14/08/2020.
//

import Foundation
import CoreData
import Combine

struct MemoryModel {
    
    public mutating func deleteMemory(_ memory: Memory) {
        if MemoryType(rawValue: Int(memory.type)) ?? MemoryType.text == .media {
            if let data = memory.data, let media = try? JSONDecoder().decode(MediaMemory.self, from: data) {
                if media.type == .video {
                    if let fileName = media.videoFileName {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let fileURL = paths[0].appendingPathComponent(fileName)
                        try? FileManager.default.removeItem(at: fileURL)
                    }
                }
            }
        }
        
        let context = PersistentStore.shared.persistentContainer.viewContext
        
        context.delete(memory)
    }
}
