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

struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator

        textField.isEditable = true
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        if nil != onDone {
            textField.returnKeyType = .done
        }
        textField.textAlignment = .center

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        if uiView.window != nil, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onDone)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
            }
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count < charLimit
        }
        
        private let charLimit = 32
    }

}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 20
    @State private var showingPlaceholder = false

    init (_ placeholder: String = "", text: Binding<String>, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: $dynamicHeight, onDone: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            .background(placeholderView, alignment: .topLeading)
    }

    var placeholderView: some View {
        Group {
            if showingPlaceholder {
                Text(placeholder).foregroundColor(.gray)
                    .padding(.leading, 4)
                    .padding(.top, 8)
            }
        }
    }
}
