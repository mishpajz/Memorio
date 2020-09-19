//
//  NewMemoryViewModel.swift
//  Memorio
//
//  Created by Michal Dobes on 11/08/2020.
//

import Foundation
import Combine
import CoreLocation
import SwiftUI

protocol NewMemoryViewModel {
    func create()
}

class NewTextMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private var model = NewMemoryModel()
    
    let placeholder = "Content..."
    
    @Published var title: String = ""
    @Published var content: String = "Content..."
    
    func create() {
        var contentFromView = content
        if contentFromView == placeholder {
            contentFromView = ""
        }
        model.createNewMemory(type: .text, title: title, content: contentFromView, data: nil)
    }
}

class NewFeelingMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private var model = NewMemoryModel()
    
    let placeholder = "Reason..."
    
    @Published var selectedFeeling: FeelingMemory = .happy
    @Published var content: String = "Reason..."
    
    let feelings = FeelingMemory.allCases
    
    func create() {
        var contentFromView = content
        if contentFromView == placeholder {
            contentFromView = ""
        }
        model.createNewMemory(type: .feeling, title: selectedFeeling.rawValue, content: contentFromView, data: nil)
    }
}

class NewActivityMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private var model = NewMemoryModel()
    
    @Published var activity: String = ""
    
    func create() {
        model.createNewMemory(type: .activity, title: activity, content: nil, data: nil)
    }
}

class NewLocationMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private(set) var model = NewMemoryModel()
    
    public var location: CLLocationCoordinate2D?
    
    func create() {
        if let location = location, let coordData = try? JSONEncoder().encode(Coordinate(location)) {
            model.createNewMemory(type: .location, title: nil, content: nil, data: coordData)
        }
    }
}

class NewMediaMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private var model = NewMemoryModel()
    
    @Published var memoryType = MediaMemory.MediaType.photo
    @Published var image = UIImage()
    @Published var videoURL: URL?
    
    func create() {
        var mediaMemory = MediaMemory(type: memoryType, imageData: nil, videoFileName: nil)
        if memoryType == .photo {
            mediaMemory.imageData = image.jpegData(compressionQuality: 1.0)
        } else if memoryType == .video {
            let url = videoURL?.lastPathComponent
            mediaMemory.videoFileName = url
        }
        if let mediaMemoryData = try? JSONEncoder().encode(mediaMemory) {
            model.createNewMemory(type: .media, title: nil, content: nil, data: mediaMemoryData)
        }
    }
}

class NewWeatherMemoryViewModel: NewMemoryViewModel, ObservableObject {
    private var model = NewMemoryModel()
    
    @Published var temp: String = ""
    @Published var type: WeatherMemory.WeatherType = .none
    @Published var description: String = ""
    @Published var humidity: String = ""
    @Published var wind: String = ""
    @Published var pressure: String = ""
    @Published var locationName: String = ""
    
    public func fetchWeather(lat: Double, lon: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(Constants.openWeatherAPIkey)"
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            guard let data = data else { return }
            
            let formatter = MeasurementFormatter()
            let numberFormatter = NumberFormatter()
            numberFormatter.maximumFractionDigits = 1
            formatter.numberFormatter = numberFormatter
            
            DispatchQueue.main.async { [weak self] in
                guard let openWeatherResponse = try? JSONDecoder().decode(OpenWeatherResponse.self, from: data) else { return }
                let tempeature = Measurement(value: openWeatherResponse.main.temp, unit: UnitTemperature.kelvin)
                self?.temp = String(formatter.string(from: tempeature))
                let responseType = OpenWeatherResponse.OpenWeatherResponseMainType(rawValue: openWeatherResponse.weather.first?.main ?? "None") ?? .none
                self?.type = OpenWeatherResponse.openWeatherResponseToWeatherType(response: responseType)
                self?.description = openWeatherResponse.weather.first?.description ?? ""
                self?.humidity = openWeatherResponse.main.humidity.rounded(toPlaces: 1).removeZerosFromEnd() + " %"
                let windSpeed = Measurement(value: openWeatherResponse.wind.speed, unit: UnitSpeed.metersPerSecond)
                self?.wind = formatter.string(from: windSpeed)
                self?.pressure = openWeatherResponse.main.pressure.rounded(toPlaces: 1).removeZerosFromEnd() + " hPa"
                self?.locationName = String(openWeatherResponse.name)
            }
            
        }.resume()
    }
    
    func create() {
        let weather = WeatherMemory(
            temp: temp,
            type: type,
            description: description,
            humidity: humidity,
            wind: wind,
            pressure: pressure,
            locationName: locationName)
        
        if let jsonData = try? JSONEncoder().encode(weather) {
            model.createNewMemory(type: .weather, title: nil, content: nil, data: jsonData)
        }
    }
    
    let weatherTypes = WeatherMemory.WeatherType.allCases
}
