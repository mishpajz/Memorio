//
//  LocationManager.swift
//  Memorio
//
//  Created by Michal Dobes on 12/08/2020.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

class LocationFetcher: NSObject, CLLocationManagerDelegate, ObservableObject {
    let manager = CLLocationManager()
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var lastKnownLocation: CLLocationCoordinate2D = CLLocationCoordinate2D() {
        willSet {
            objectWillChange.send()
        }
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
        didSet {
            switch locationStatus {
            case .authorizedAlways, .authorizedWhenInUse: isAuthorized = true
            default: isAuthorized = false
            }
        }
    }
    
    @Published var isAuthorized: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastKnownLocation = location.coordinate
    }
}
