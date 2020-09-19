//
//  UIViewRepresentations.swift
//  Memorio
//
//  Created by Michal Dobes on 09/08/2020.
//

import SwiftUI
import UIKit
import MapKit
import AVKit
import SafariServices
import MessageUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.delegate = context.coordinator
        view.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        view.backgroundColor = UIColor.clear
        view.text = placeholder
        view.textColor = UIColor.tertiaryLabel
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var control: TextView

        init(_ control: TextView) {
            self.control = control
        }

        func textViewDidChange(_ textView: UITextView) {
            control.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == control.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = control.placeholder
                textView.textColor = UIColor.tertiaryLabel
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var annotations: [MKPointAnnotation]
    @State var cornerRadius: CGFloat = 0
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.centerCoordinate = centerCoordinate
        mapView.layer.cornerRadius = cornerRadius
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
            view.showAnnotations(view.annotations, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
    }
}

struct DetailMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var annotations: [MKPointAnnotation]
    @State var cornerRadius: CGFloat = 0
    @Binding var thumbnail: UIImage
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.centerCoordinate = centerCoordinate
        mapView.layer.cornerRadius = cornerRadius
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
            view.showAnnotations(view.annotations, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: DetailMapView

        init(_ parent: DetailMapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }
        
        func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
            if fullyRendered {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let render = UIGraphicsImageRenderer(size: mapView.bounds.size)
                    let img = render.image { (ctx) in
                        mapView.drawHierarchy(in: mapView.bounds, afterScreenUpdates: true)
                    }
                    self.parent.thumbnail = img
                }
            }
        }
    }
}

struct Camera: UIViewControllerRepresentable {
    @Binding var capturedPhoto: UIImage?
    @Binding var urlVideo: URL?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, capturedPhoto: $capturedPhoto, isPresented: $isPresented, urlVideo: $urlVideo)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        
        var parent: Camera
        
        @Binding var capturedPhoto: UIImage?
        @Binding var urlVideo: URL?
        @Binding var isPresented: Bool

        init(_ parent: Camera, capturedPhoto: Binding<UIImage?>, isPresented: Binding<Bool>, urlVideo: Binding<URL?>) {
            self.parent = parent
            self._capturedPhoto = capturedPhoto
            self._isPresented = isPresented
            self._urlVideo = urlVideo
        }
        
        func didCapturePhoto(_ photo: UIImage) {
            capturedPhoto = photo
            urlVideo = nil
            isPresented = false
        }
        
        func didCaptureVideo(_ url: URL) {
            urlVideo = url
            capturedPhoto = nil
            isPresented = false
        }
        
        func didCancel() {
            isPresented = false
        }
        
    }
    
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    @Binding var isPresented: Bool
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    var urlToRemove: URL? = nil

    func makeUIViewController(context: Context) -> ActivityViewWrapper {
        ActivityViewWrapper(activityItems: activityItems, applicationActivities: applicationActivities, isPresented: $isPresented, excludedActivityTypes: excludedActivityTypes, urlToRemove: urlToRemove)
    }

    func updateUIViewController(_ uiViewController: ActivityViewWrapper, context: Context) {
        uiViewController.isPresented = $isPresented
        uiViewController.updateState()
    }
}

class ActivityViewWrapper: UIViewController {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    var excludedActivityTypes: [UIActivity.ActivityType]?
    var urlToRemove: URL?
    
    var isPresented: Binding<Bool>

    init(activityItems: [Any], applicationActivities: [UIActivity]? = nil, isPresented: Binding<Bool>, excludedActivityTypes: [UIActivity.ActivityType]? = nil, urlToRemove: URL? = nil) {
        self.activityItems = activityItems
        self.applicationActivities = applicationActivities
        self.isPresented = isPresented
        self.excludedActivityTypes = excludedActivityTypes
        self.urlToRemove = urlToRemove
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        guard parent != nil else {return}
        let isActivityPresented = presentedViewController != nil
        if isActivityPresented != isPresented.wrappedValue {
            if !isActivityPresented {
                let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
                controller.excludedActivityTypes = excludedActivityTypes
                controller.completionWithItemsHandler = { (activityType, completed, _, _) in
                    if let url = self.urlToRemove {
                        try? FileManager.default.removeItem(at: url)
                    }
                    self.isPresented.wrappedValue = false
                }
                if UIDevice.current.userInterfaceIdiom == .pad {
                    controller.popoverPresentationController?.sourceView = self.view
                    present(controller, animated: true, completion: nil)
                } else {
                    present(controller, animated: true, completion: nil)
                }
            }
            else {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

struct Player: UIViewControllerRepresentable {
    
    var player: AVPlayer
    var backgroundColor: UIColor = UIColor.systemBackground
    
    func makeUIViewController(context: Context) -> AVPlayerViewController{
        
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspect
        view.allowsPictureInPicturePlayback = false
        view.view.backgroundColor = backgroundColor
        return view
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}

struct SafariView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    var url: URL

    func makeCoordinator() -> SafariView.Coordinator {
        return Coordinator(isShowing: $isShowing)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let vc = SFSafariViewController(url: url)
        vc.delegate = context.coordinator
        vc.preferredControlTintColor = UIColor(named: "AccentColor")
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController,
                                context: UIViewControllerRepresentableContext<SafariView>) {

    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            isShowing = false
        }
    }
}

struct MailView: UIViewControllerRepresentable {

    @Binding var isShowing: Bool
    var recipient: String
    var subject: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var isShowing: Bool

        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            isShowing = false
        }
    }

    func makeCoordinator() -> MailView.Coordinator {
        return Coordinator(isShowing: $isShowing)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
