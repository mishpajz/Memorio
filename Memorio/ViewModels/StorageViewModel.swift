//
//  StorageViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class StorageViewModel: ObservableObject {
    
    @Published public var currentExportSettings: VideoQualitySettings = .medium
    private var memoryModel = MemoryModel()
    
    public func saveQuality() {
        UserDefaults.standard.setValue(currentExportSettings.rawValue, forKey: Constants.videoExportSettings)
    }
    
    public var totalDiskSpaceInBytes: Int {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.intValue
            return space!
        } catch {
            return 0
        }
    }
    
    public var freeDiskSpaceInBytes: Int {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.intValue
            return freeSpace!
        } catch {
            return 0
        }
    }
    
    public var usedDiskSpaceInBytes: Int {
        totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
    
    public var appDiskSpaceInBytes: Int {
        appSize()
    }
    
    public func format(bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    public func clearCache() {
        // Cache folder cleanup
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        do {
            let cacheContents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for file in cacheContents {
                do {
                    try FileManager.default.removeItem(at: file)
                } catch {
                    print(#function, error)
                }
            }
        } catch {
            print(#function, error)
        }
        
        // Documents folder cleanup
        let context = PersistentStore.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Memory.fetchRequest()
        let predicate = NSPredicate(format: "type == %ld", MemoryType.media.rawValue)
        fetchRequest.predicate = predicate
        
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            if let memories = try context.fetch(fetchRequest) as? [Memory] {
                let videoUrls = memories
                    .compactMap { (memory) -> MediaMemory? in
                    if let data = memory.data {
                        if let mediaMemory = try? JSONDecoder().decode(MediaMemory.self, from: data) {
                            return mediaMemory
                        }
                    }
                    return nil
                }
                    .filter({ $0.type == .video })
                    .compactMap { $0.videoFileName ?? nil}
                let documentFiles = try FileManager.default.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil)
                for file in documentFiles {
                    if !videoUrls.contains(file.lastPathComponent) {
                        do {
                            try FileManager.default.removeItem(at: file)
                        } catch {
                            print(#function, error)
                        }
                    }
                }
            }
        } catch {
            print(#function, error)
        }
        
    }
    
    public func deleteAllMemories() {
        let context = PersistentStore.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Memory.fetchRequest()
        
        do {
            if let memories = try context.fetch(fetchRequest) as? [Memory] {
                for memory in memories {
                    memoryModel.deleteMemory(memory)
                }
            }
        } catch {
            print(#function, error)
        }
        PersistentStore.shared.save()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.clearCache()
        }
    }
    
    private func appSize() -> Int {

        // create list of directories
        var paths = [Bundle.main.bundlePath] // main bundle
        let docDirDomain = FileManager.SearchPathDirectory.documentDirectory
        let docDirs = NSSearchPathForDirectoriesInDomains(docDirDomain, .userDomainMask, true)
        if let docDir = docDirs.first {
            paths.append(docDir) // documents directory
        }
        let libDirDomain = FileManager.SearchPathDirectory.libraryDirectory
        let libDirs = NSSearchPathForDirectoriesInDomains(libDirDomain, .userDomainMask, true)
        if let libDir = libDirs.first {
            paths.append(libDir) // library directory
        }
        paths.append(NSTemporaryDirectory() as String) // temp directory

        // combine sizes
        var totalSize: Int = 0
        for path in paths {
            if let size = bytesIn(directory: path) {
                totalSize += size
            }
        }
        return totalSize
    }

    private func bytesIn(directory: String) -> Int? {
        let fm = FileManager.default
        guard let subdirectories = try? fm.subpathsOfDirectory(atPath: directory) as NSArray else {
            return nil
        }
        let enumerator = subdirectories.objectEnumerator()
        var size: UInt64 = 0
        while let fileName = enumerator.nextObject() as? String {
            do {
                let fileDictionary = try fm.attributesOfItem(atPath: directory.appending("/" + fileName)) as NSDictionary
                size += fileDictionary.fileSize()
            } catch let err {
                print(#function, "err getting attributes of file \(fileName): \(err.localizedDescription)")
            }
        }
        return Int(size)
    }
    
    init() {
        if UserDefaults.standard.value(forKey: Constants.videoExportSettings) != nil {
            currentExportSettings = VideoQualitySettings(rawValue: UserDefaults.standard.value(forKey: Constants.videoExportSettings) as! String)!
        } else {
            currentExportSettings = .medium
            UserDefaults.standard.setValue(VideoQualitySettings.medium.rawValue, forKey: Constants.videoExportSettings)
        }
    }
}

public enum VideoQualitySettings: String, CaseIterable, Identifiable {
    case medium = "AVAssetExportPreset1280x720"
    case high = "AVAssetExportPreset3840x2160"
    
    public var id: String { rawValue }
}
