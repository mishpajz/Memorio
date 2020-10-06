//
//  Extensions.swift
//  Memorio
//
//  Created by Michal Dobes on 11/08/2020.
//

import Foundation
import CoreLocation
import SwiftUI
import UIKit
import AVKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    static func item(data: Data) -> CLLocationCoordinate2D? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? CLLocationCoordinate2D
    }
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16 //maximum digits in Double after dot (maximum precision)
        return String(formatter.string(from: number) ?? "")
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Notification.Name {
    static let newDataInCoreData = Notification.Name("newDataInCoreData")
    static let shouldLogIn = Notification.Name("shouldLogIn")
    static let transactionFinished = Notification.Name("transactionFinished")
}

extension CLLocationCoordinate2D {
    init(_ coordinate: Coordinate) {
        self = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Coordinate {
    init(_ coordinate: CLLocationCoordinate2D) {
        self = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Color {
    public func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}

extension UIColor {
    func mix(with color: UIColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.renderedImage
    }
    
    func takeScreenshotWithoutBackground(origin: CGPoint, size: CGSize) -> UIImage? {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        hosting.view.backgroundColor = .clear
        return hosting.view.renderedImageByPNG
    }
}

extension UIView {
    var renderedImage: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
    
    var renderedImageByPNG: UIImage {
        // rect of capure
        let rect = self.bounds
        // create the context of bitmap
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        // get a image from current context bitmap
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let imageData = capturedImage?.pngData() else { return UIImage() }
        return UIImage.init(data: imageData) ?? UIImage()
    }
}

extension Int {
    func secondsToTime() -> String {
        let (m,s) = ((self % 3600) / 60, (self % 3600) % 60)
        
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        return "\(m_string):\(s_string)"
    }
}

struct BlurredBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)).cornerRadius(13).transition(.identity))
    }
}

struct RestrictedWidth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 672)
    }
}

extension View {
    func blurredBackground() -> some View {
        self.modifier(BlurredBackground())
    }
}

extension View {
    func restrictedWidth() -> some View {
        self.modifier(RestrictedWidth())
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        return Binding(
            get: { self.wrappedValue },
            set: { selection in
                self.wrappedValue = selection
                handler(selection)
        })
    }
}

