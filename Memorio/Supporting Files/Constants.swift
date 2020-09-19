//
//  Constants.swift
//  Memorio
//
//  Created by Michal Dobes on 12/08/2020.
//

import Foundation
import SwiftUI

public struct Constants {
    public static let openWeatherAPIkey = "***REMOVED***"
    
    // MARK: - UI
        // Gradients
    public static let tetriaryGradient = LinearGradient(gradient: Gradient(colors: [Constants.tetriaryColor.lighter(), Constants.tetriaryColor.darker()]), startPoint: .top, endPoint: .bottom)
    public static let secondaryGradient = LinearGradient(gradient: Gradient(colors: [Constants.secondaryColor.lighter(), Constants.secondaryColor.darker()]), startPoint: .top, endPoint: .bottom)
    public static let mainGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0, blue: 0.6549019608, alpha: 1)), Color(#colorLiteral(red: 1, green: 0, blue: 0.431372549, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    
        // Colors
    public static let accentColor = Color("AccentColor")
    public static let deleteColor = Color("deleteColor")
    public static let mainColor = Color("mainColor")
    public static let popupBackground = Color("popupBackground")
    public static let quaternaryColor = Color("quaternaryColor")
    public static let secondaryColor = Color("secondaryColor")
    public static let tetriaryColor = Color("tetriaryColor")
    public static let shadowBackground = Color("shadowBackground")
    
    // MARK: - App
    public static let appId = "1475512225"
    
        // User Defaults
    public static let videoExportSettings = "VideoExportSettings"
    public static let isNotFirstLaunch = "isNotFirstLaunch"
    
        // URLs
    public static let appWebsite = URL(string: "https://memorio.michaldobes.eu")!
    public static let devWebsite = URL(string: "https://michaldobes.eu")!
    public static let privacyPolicy = URL(string: "https://traktic.michaldobes.eu/privacy-policy/")!
    public static let appInAppStoreWebsite = URL(string: "https://itunes.apple.com/us/app/traktic/id\(Constants.appId)")!
    
        // Emails
    public static let appEmail = "memorio@michaldobes.eu"
    public static let devEmail = "contactme@michaldobes.eu"
    
        // Store
    public static let sharedSecret = "***REMOVED***"
}
