//
//  MemoryViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 13/08/2020.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Combine

class MemoryViewModel: ObservableObject {
    
    // Main values
    @Published var selectedIndex = 0 {
        didSet {
            setViewValues()
        }
    }
    @Binding var isPresented: Bool
    
    @Published private var model = MemoryModel()
    
    private var subscriptionModel = PlusModel()
    
    private var memories: [Memory]
    
    private var memoriesToDisplay: [Memory] {
        return memories.filter { (memory) -> Bool in
            return !memory.isDeleted
        }
    }

    
    // View values
    @Published var title = ""
    @Published var content = ""
    
    @Published var feelingEmoji = ""
    
    @Published var weatherImageName = ""
    @Published var weatherHumidity = ""
    @Published var weatherWind = ""
    @Published var weatherPressure = ""
    @Published var weatherLocation = ""
    
    @Published var location = CLLocationCoordinate2D()
    @Published var locationAnnotation = [MKPointAnnotation]()
    
    @Published var thumbImage = UIImage()
    
    @Published var mediaType = MediaMemory.MediaType.photo
    @Published var mediaImage = UIImage()
    @Published var mediaVideoUrl: URL?
    
    // Computed values
    public var currentMemory: Memory {
        memoriesToDisplay[selectedIndex]
    }
    
    public var currentMemoryType: MemoryType {
        return MemoryType(rawValue: Int(currentMemory.type)) ?? MemoryType.text
    }
    
    public var currentMemoryDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: currentMemory.date ?? Date())
    }
    
    public var currentMemoryTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: currentMemory.date ?? Date())
    }
    
    public var memoryCount: Int {
        return memoriesToDisplay.count
    }
    
    public var currentMemoryPosition: Int {
        return selectedIndex + 1
    }
    
    public func nextMemory() {
        if memoriesToDisplay.count == (selectedIndex + 1) {
            isPresented = false
        } else {
            selectedIndex += 1
        }
    }
    
    public func prevMemory() {
        if selectedIndex == 0 {
            isPresented = false
        } else {
            selectedIndex -= 1
        }
    }
    
    public func setViewValues() {
        switch currentMemoryType {
        case .activity:
            title = currentMemory.title ?? ""
        case .feeling:
            if let currentMemoryTitle = currentMemory.title, let feeling = FeelingMemory(rawValue: currentMemoryTitle) {
                title = feeling.rawValue.capitalizingFirstLetter()
                feelingEmoji = feeling.emojiForFeeling()
                content = currentMemory.content ?? ""
            }
        case .location:
            if let data = currentMemory.data, let coorinate = try? JSONDecoder().decode(Coordinate.self, from: data) {
                let locationCoordinate = CLLocationCoordinate2D(coorinate)
                location = locationCoordinate
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                locationAnnotation = [annotation]
            }
        case .media:
            if let data = currentMemory.data, let media = try? JSONDecoder().decode(MediaMemory.self, from: data) {
                if media.type == .photo {
                    mediaType = .photo
                    if let imageData = media.imageData {
                        mediaImage = UIImage(data: imageData, scale: 1.0) ?? UIImage()
                    }
                } else if media.type == .video {
                    mediaType = .video
                    if let fileName = media.videoFileName {
                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                        let fileURL = paths[0].appendingPathComponent(fileName)
                        mediaVideoUrl = fileURL
                    }
                }
            }
        case .text:
            title = currentMemory.title ?? ""
            content = currentMemory.content ?? ""
        case .weather:
            if let data = currentMemory.data, let weatherMemory = try? JSONDecoder().decode(WeatherMemory.self, from: data) {
                weatherImageName = weatherMemory.type.rawValue
                title = weatherMemory.temp
                content = weatherMemory.description
                weatherHumidity = weatherMemory.humidity
                weatherWind = weatherMemory.wind
                weatherPressure = weatherMemory.pressure
                weatherLocation = weatherMemory.locationName
            }
        }
    }
    
    public func deleteCurrentMemory() {
        let index = memories.firstIndex { (memory) -> Bool in
            memory.id == memoriesToDisplay[selectedIndex].id
        }
        if let index = index {
            if memoryCount == 1 {
                model.deleteMemory(memories[index])
                PersistentStore.shared.save()
                isPresented = false
            } else {
                if selectedIndex != 0 {
                    selectedIndex -= 1
                }
                model.deleteMemory(memories.remove(at: index))
            }
        }
        NotificationCenter.default.post(name: .newDataInCoreData, object: nil)
    }
    
    public func isPlus() -> Bool {
        subscriptionModel.isPlus()
    }
    
    init(memories: [Memory], isPresented: Binding<Bool>) {
        self.memories = memories
        self._isPresented = isPresented
        setViewValues()
    }
}
