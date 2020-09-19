//
//  OpenWeather.swift
//  Memorio
//
//  Created by Michal Dobes on 12/08/2020.
//

import Foundation

struct OpenWeatherResponse: Codable {
    var weather: [OpenWeatherResponseWeather]
    var main: OpenWeatherResponseMain
    var wind: OpenWeatherResponseWind
    var name: String
    
    struct OpenWeatherResponseWeather: Codable {
        var main: String
        var description: String
    }
    struct OpenWeatherResponseMain: Codable {
        var temp: Double
        var pressure: Double
        var humidity: Double
    }
    struct OpenWeatherResponseWind: Codable {
        var speed: Double
    }
    
    enum OpenWeatherResponseMainType: String {
        case clouds = "Clouds"
        case clear = "Clear"
        case mist = "Mist"
        case smoke = "Smoke"
        case haze = "Haze"
        case dust = "Dust"
        case fog = "Fog"
        case ash = "Ash"
        case sand = "Sand"
        case squall = "Squall"
        case tornado = "Tornado"
        case snow = "Snow"
        case rain = "Rain"
        case drizzle = "Drizzle"
        case thunderstorm = "Thunderstorm"
        case none = "None"
    }
    
    static func openWeatherResponseToWeatherType(response: OpenWeatherResponseMainType) -> WeatherMemory.WeatherType {
        switch response {
        case .clouds, .squall:
            return .cloudy
        case .clear:
            return .sunny
        case .mist, .fog, .haze:
            return .mist
        case .dust, .sand, .smoke, .ash:
            return .fog
        case .tornado:
            return .tornado
        case .snow:
            return .snow
        case .rain, .drizzle:
            return .rain
        case .thunderstorm:
            return .thunder
        default:
            return .none
        }
    }
}
