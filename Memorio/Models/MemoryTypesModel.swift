//
//  MemoryModel.swift
//  Memorio
//
//  Created by Michal Dobes on 11/08/2020.
//

import Foundation
import CoreData
import Combine

public enum MemoryType: Int {
    case text
    case feeling
    case location
    case activity
    case media
    case weather
}

struct Coordinate: Codable, Hashable {
    let latitude, longitude: Double
}

public enum FeelingMemory: String, CaseIterable, Identifiable {
    case happy
    case sad
    case stressed
    case anxious
    case fabulous
    case angry
    case ill
    case cool
    case embarrassed
    case nervous
    case goofy
    case suprised
    case quiet
    case annoyed
    case tired
    case excited
    case bored
    case frustrated
    case funny
    case proud
    case cold
    case hot
    case hungover
    case thoughtful
    case smart
    case curious
    case lonely
    case lovestruck
    case ecstatic
    case sick
    case cute
    case crying
    case celebratory
    case freaked
    case sulk
    case overwhelmed
    
    
    public var id: String { self.rawValue }
    
    public func emojiForFeeling() -> String {
        switch self {
        case .happy:
            return "😊"
        case .sad:
            return "😞"
        case .stressed:
            return "😬"
        case .anxious:
            return "😰"
        case .fabulous:
            return "🤩"
        case .angry:
            return "😡"
        case .ill:
            return "😷"
        case .cool:
            return "😎"
        case .embarrassed:
            return "🤭"
        case .nervous:
            return "🙂"
        case .goofy:
            return "😜"
        case .suprised:
            return "😯"
        case .quiet:
            return "🤫"
        case .annoyed:
            return "🙄"
        case .tired:
            return "😴"
        case .excited:
            return "😝"
        case .bored:
            return "🥱"
        case .frustrated:
            return "😫"
        case .funny:
            return "😂"
        case .proud:
            return "😏"
        case .cold:
            return "🥶"
        case .hot:
            return "🥵"
        case .hungover:
            return "🤮"
        case .thoughtful:
            return "🤔"
        case .smart:
            return "🤓"
        case .curious:
            return "😲"
        case .lonely:
            return "😓"
        case .lovestruck:
            return "😍"
        case .ecstatic:
            return "☺️"
        case .sick:
            return "🤢"
        case .cute:
            return "🥺"
        case .crying:
            return "😭"
        case .celebratory:
            return "🥳"
        case .freaked:
            return "😱"
        case .sulk:
            return "😤"
        case .overwhelmed:
            return "🤯"
        }
    }
}

public struct WeatherMemory: Codable {
    public var temp: String
    public var type: WeatherType
    public var description: String
    public var humidity: String
    public var wind: String
    public var pressure: String
    public var locationName: String
    
    public enum WeatherType: String, CaseIterable, Identifiable, Codable {
        case cloudy
        case fog
        case mist
        case rain
        case snow
        case sunny
        case thunder
        case tornado
        case none
        
        public var id: String { self.rawValue }
    }
}

public struct MediaMemory: Codable {
    public var type: MediaType
    public var imageData: Data?
    public var videoFileName: String?
    
    public enum MediaType: String, Codable {
        case photo
        case video
    }
}
