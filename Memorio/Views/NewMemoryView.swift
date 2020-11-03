//
//  NewView.swift
//  Memorio
//
//  Created by Michal Dobes on 09/08/2020.
//

import SwiftUI
import MapKit
import AVKit

struct NewView: View {
    @Binding var isPresented: Bool
    @State var isPresenting: Bool = false
    @State var memoryType: MemoryType = .text
    @Binding var isShowingDoneAlert: Bool
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme
    
    @Namespace private var newAnimation
    
    var body: some View {
        if !isPresenting {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    content(for: geometry.size)
                }
            }.restrictedWidth()
        } else {
            newView
        }
    }
    
    @ViewBuilder
    private var newView: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .foregroundColor(Constants.popupBackground)
            switch memoryType {
            case .text:
                NewText(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            case .feeling:
                NewFeeling(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            case .location:
                NewLocation(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            case .activity:
                NewActivity(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            case .media:
                NewMedia(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            case .weather:
                NewWeather(isPresented: $isPresented, isPresenting: $isPresenting, isShowingDoneAlert: $isShowingDoneAlert)
            }
        }
    }
    
    private func content(for size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(Constants.popupBackground)
                .edgesIgnoringSafeArea(.bottom)
                .transition(.identity)
            VStack {
                HStack {
                    Text("New Memory")
                        .font(Font.system(size: 28, weight: .black))
                    Spacer()
                    CloseButton(close: $isPresented, withAAnimation: true)
                }
                .padding(30)
                VStack {
                    HStack {
                        button(title: "Media", imageName: "camera", type: .media)
                        button(title: "Text", imageName: "doc.text", type: .text)
                    }
                    HStack {
                        button(title: "Feeling", imageName: "smiley", type: .feeling)
                        button(title: "Weather", imageName: "cloud.sun", type: .weather)
                    }
                    HStack {
                        button(title: "Location", imageName: "mappin.and.ellipse", type: .location)
                        button(title: "Activity", imageName: "gamecontroller", type: .activity)
                    }
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 15)
            }
        }
        .frame(maxHeight: (size.height/4)*3, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private func button(title: String, imageName: String, type: MemoryType) -> some View {
        Button {
            isPresenting = true
            memoryType = type
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(colorScheme == .dark ? Constants.quaternaryColor : Constants.popupBackground)
                    .shadow(radius: 5)
                VStack {
                    Spacer()
                    Image(systemName: imageName)
                        .font(Font.system(size: 50, weight: .semibold))
                    Spacer()
                    Text(title)
                        .font(Font.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.primary)
                }
                .padding(3)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .hoverEffect()
    }
}



struct NewText: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var newTextModel = NewTextMemoryViewModel()
    @State var isAbleToDone: Bool = true
    @Binding var isShowingDoneAlert: Bool
    
    var body: some View {
        VStack {
            NewTopBar(isPresenting: $isPresenting, isPresented: $isPresented, isAbleToDone: $isAbleToDone, model: newTextModel, isShowingDoneAlert: $isShowingDoneAlert, title: "New Text Memory")
            content
                .restrictedWidth()
        }
    }
    
    private var content: some View {
        VStack {
            TextField("Title", text: $newTextModel.title)
                .padding()
                .textFieldStyle(PlainTextFieldStyle())
                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                .padding(.bottom, 10)
            TextView(text: $newTextModel.content, placeholder: newTextModel.placeholder)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                .font(Font.system(size: 17, weight: .regular))
        }
        .padding(15)
    }
}

struct NewFeeling: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var newFeelingModel = NewFeelingMemoryViewModel()
    @State var isAbleToDone: Bool = true
    @Binding var isShowingDoneAlert: Bool
    
    var body: some View {
        VStack {
            NewTopBar(isPresenting: $isPresenting, isPresented: $isPresented, isAbleToDone: $isAbleToDone, model: newFeelingModel, isShowingDoneAlert: $isShowingDoneAlert, title: "New Feeling Memory")
            content
                .restrictedWidth()
        }
    }
    
    private var content: some View {
        VStack {
            Picker("Feeling", selection: $newFeelingModel.selectedFeeling) {
                ForEach(newFeelingModel.feelings) { feeling in
                    Text("\(feeling.rawValue.capitalizingFirstLetter()) \(feeling.emojiForFeeling())").tag(feeling)
                }
            }
            TextView(text: $newFeelingModel.content, placeholder: newFeelingModel.placeholder)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                .font(Font.system(size: 17, weight: .regular))
        }
        .padding(15)
    }
}

struct NewActivity: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var newActivityModel = NewActivityMemoryViewModel()
    @State var isAbleToDone: Bool = true
    @Binding var isShowingDoneAlert: Bool
    
    var body: some View {
        VStack {
            NewTopBar(isPresenting: $isPresenting, isPresented: $isPresented, isAbleToDone: $isAbleToDone, model: newActivityModel, isShowingDoneAlert: $isShowingDoneAlert, title: "New Activity Memory")
            content
                .restrictedWidth()
        }
    }
    
    private var content: some View {
        VStack {
            Spacer()
            TextField("Activity", text: $newActivityModel.activity)
                .padding()
                .textFieldStyle(PlainTextFieldStyle())
                .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
            Spacer()
        }
        .padding(15)
    }
}

struct NewLocation: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @ObservedObject var lm = LocationFetcher()
    @ObservedObject var newLocationModel = NewLocationMemoryViewModel()
    @Binding var isShowingDoneAlert: Bool
    @State var presentingAlert = false
    @State private var locations = [MKPointAnnotation]()
    @State var alreadyPresentedCantFigureOutLocation = false
    
    
    var body: some View {
        VStack {
            NewTopBar(isPresenting: $isPresenting, isPresented: $isPresented, isAbleToDone: $lm.isAuthorized, model: newLocationModel, isShowingDoneAlert: $isShowingDoneAlert, title: "New Location Memory")
            content
        }
    }
    
    private var content: some View {
        MapView(centerCoordinate: $lm.lastKnownLocation, annotations: $locations, cornerRadius: 15)
            .padding(15)
            .cornerRadius(15)
            .onChange(of: lm.lastKnownLocation, perform: { (location) in
                if lm.isAuthorized {
                    newLocationModel.location = location
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    locations = []
                    locations.append(annotation)
                } else {
                    locations = []
                }
            })
            .onChange(of: lm.locationStatus, perform: { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    presentingAlert = false
                default:
                    if !alreadyPresentedCantFigureOutLocation {
                        presentingAlert = true
                    }
                    alreadyPresentedCantFigureOutLocation = true
                }
            }
            )
            .alert(isPresented: $presentingAlert) { () -> Alert in
                Alert(title: Text("Can't access location."), message: Text("To allow saving your location to your Memories, please allow access in settings."), dismissButton: .default(Text("Ok")))
            }
    }
}

struct NewMedia: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @State var isAbleToDone: Bool = true
    @State var pickerIsShown: Bool = true
    @State var chosenImage: UIImage?
    @State var urlVideo: URL?
    @ObservedObject var newMediaModel = NewMediaMemoryViewModel()
    @Binding var isShowingDoneAlert: Bool
    @State var textAdded = false
    @State var overviewText = ""
    @GestureState var overviewTextDragOffsetInGesture = CGSize.zero
    @State var overviewTextDragOffset = CGSize.zero
    @Environment(\.scenePhase) private var scenePhase
    @State var mediaSize = CGSize.zero
    @State var mediaGlobalPoint = CGPoint()
    
    var body: some View {
        ZStack {
            VStack {
                mediaTopBar
                content
                    .restrictedWidth()
            }
            .gesture(textAdditionGesture)
            if pickerIsShown {
                Camera(capturedPhoto: $chosenImage, urlVideo: $urlVideo, isPresented: $pickerIsShown)
                    .ignoresSafeArea(.all, edges: .all)
                    .statusBar(hidden: pickerIsShown)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: scenePhase, perform: { value in
            if value == .background {
                if urlVideo != nil {
                    try? FileManager.default.removeItem(at: urlVideo!)
                }
                urlVideo = nil
            }
        })
    }
    
    private var content: some View {
        VStack(alignment: .center) {
            media(editing: true)
            Button {
                if isAbleToDone {
                    pickerIsShown = true
                    if urlVideo != nil {
                        try? FileManager.default.removeItem(at: urlVideo!)
                    }
                    urlVideo = nil
                    textAdded = false
                    overviewText = ""
                    overviewTextDragOffset = CGSize.zero
                }
            } label: {
                Image(systemName: "camera.circle.fill")
                    .font(Font.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Rectangle()
                                    .fill(isAbleToDone ? Constants.tetriaryGradient : Constants.secondaryGradient)
                                    .cornerRadius(15)
                                    .shadow(color: isAbleToDone ? Constants.tetriaryColor : Constants.secondaryColor, radius: 5, x: 0, y: 0))
                    .padding()
            }
        }
        .padding(15)
    }
    
    private func media(editing: Bool) -> some View {
        GeometryReader { geometry in
            trueMedia(editing: editing, size: geometry.size)
                .frame(maxWidth: .infinity)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .onAppear {
                    mediaGlobalPoint = geometry.frame(in: .global).origin
                }
        }
    }
    
    private func trueMedia(videoOpacity: Double = 1.0, editing: Bool, size: CGSize) -> some View {
        ZStack {
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    if let image = chosenImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .onAppear {
                                let imageWidth = chosenImage?.size.width ?? 0
                                let imageHeight = chosenImage?.size.height ?? 0
                                
                                if imageWidth > imageHeight {
                                    let width = min(size.width, imageWidth)
                                    let height = size.width / imageWidth * imageHeight
                                    
                                    mediaSize = CGSize(width: width, height: height)
                                } else if imageHeight > imageWidth {
                                    let width = size.height / imageHeight * imageWidth
                                    let height = min(size.height, imageHeight)
                                    
                                    mediaSize = CGSize(width: width, height: height)
                                } else {
                                    let smallestSide = min(size.height, size.width)
                                    
                                    mediaSize = CGSize(width: smallestSide, height: smallestSide)
                                }
                            }
                    } else if let url = urlVideo {
                        MediaPlayer(player: AVPlayer(url: url), backgroundColor: UIColor(named: "popupBackground")!)
                            .opacity(videoOpacity)
                            .onAppear {
                                if let track = AVURLAsset(url: url).tracks(withMediaType: .video).first {
                                    let trackSize = track.naturalSize.applying(track.preferredTransform)
                                    
                                    if trackSize.width > trackSize.height {
                                        let width = min(size.width, trackSize.width)
                                        let height = size.width / trackSize.width * trackSize.height
                                        
                                        mediaSize = CGSize(width: width, height: height)
                                    } else if trackSize.height > trackSize.width {
                                        let width = size.height / trackSize.height * trackSize.width
                                        let height = min(size.height, trackSize.height)
                                        
                                        mediaSize = CGSize(width: width, height: height)
                                    } else {
                                        let smallestSide = min(size.height, size.width)
                                        
                                        mediaSize = CGSize(width: smallestSide, height: smallestSide)
                                    }
                                }
                            }
                    } else {
                        Spacer()
                    }
                }
            }
            if textAdded {
                textAddition
                    .overlay(
                        Button(action: {
                            textAdded = false
                            overviewText = ""
                            overviewTextDragOffset = .zero
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(Font.system(size: 22, weight: .bold))
                                .foregroundColor(Constants.deleteColor)
                                .background(Circle().fill(Color(UIColor.systemBackground)))
                                .opacity(editing ? 1 : 0)
                        })
                        .offset(x: -10, y: overviewTextDragOffset.height + overviewTextDragOffsetInGesture.height)
                        , alignment: .topTrailing)
            }
        }
    }
    
    private var textAddition: some View {
        return TextField("Text", text: $overviewText)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .font(Font.system(size: 17, weight: .regular))
            .padding()
            .background(RoundedRectangle(cornerRadius: 13).fill(Color(#colorLiteral(red: 0.08784847122, green: 0.08784847122, blue: 0.08784847122, alpha: 0.6))))
            .padding()
            .offset(x: 0, y: overviewTextDragOffset.height + overviewTextDragOffsetInGesture.height)
            .gesture(DragGesture()
                        .updating($overviewTextDragOffsetInGesture, body: { (value, state, transaction) in
                            if overviewTextDragOffset.height + value.translation.height > overviewTextMaxHeightOffset {
                                state.height = overviewTextMaxHeightOffset - overviewTextDragOffset.height
                            } else if overviewTextDragOffset.height + value.translation.height < -overviewTextMaxHeightOffset {
                                state.height = -overviewTextMaxHeightOffset - overviewTextDragOffset.height
                            } else {
                                state = value.translation
                            }
                        })
                        .onEnded( { value in
                            if overviewTextDragOffset.height + value.translation.height > overviewTextMaxHeightOffset {
                                overviewTextDragOffset.height = overviewTextMaxHeightOffset
                            } else if overviewTextDragOffset.height + value.translation.height  < -overviewTextMaxHeightOffset {
                                overviewTextDragOffset.height = -overviewTextMaxHeightOffset
                            } else {
                                overviewTextDragOffset.height = value.translation.height + overviewTextDragOffset.height
                            }
                        })
            )
    }
    
    private var mediaTopBar: some View {
        HStack {
            if isAbleToDone {
                CloseButton(close: $isPresented, withAAnimation: true, urlToRemove: $urlVideo)
            } else {
                ProgressView()
            }
            Spacer()
            Text("New Media Memory")
                .font(Font.system(size: 17, weight: .bold))
            Spacer()
            Button {
                withAnimation {
                    if isAbleToDone {
                        if chosenImage != nil {
                            newMediaModel.memoryType = .photo
                            isAbleToDone = false
                            newMediaModel.image = media(editing: false).takeScreenshot(origin: mediaGlobalPoint, size: mediaSize)
                            newMediaModel.create()
                            isShowingDoneAlert = true
                            isPresented = false
                        } else if urlVideo != nil {
                            newMediaModel.memoryType = .video
                            isAbleToDone = false
                            if textAdded, let overlayImage = textAddition.takeScreenshotWithoutBackground(origin: mediaGlobalPoint, size: mediaSize) {
                                let videoCompositor = VideoCompositor()
                                DispatchQueue(label: "mdobes.memorio.imageprocessing").async {
                                    videoCompositor.addViewTo(videoURL: urlVideo!, watermark: overlayImage) { (url, error) in
                                        DispatchQueue.main.async {
                                            if let url = url {
                                                newMediaModel.videoURL = url
                                                newMediaModel.create()
                                                isShowingDoneAlert = true
                                                isPresented = false
                                            }
                                        }
                                    }
                                }
                            } else {
                                newMediaModel.videoURL = urlVideo
                                newMediaModel.create()
                                isShowingDoneAlert = true
                                isPresented = false
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(Font.system(size: 25, weight: .bold))
                    .foregroundColor(isAbleToDone && canCreate ? Constants.tetriaryColor : Constants.quaternaryColor)
            }
            .hoverEffect()
        }
            .padding()
            .padding(.top, 5)
    }
    
    private var textAdditionGesture: some Gesture {
        return LongPressGesture()
            .onEnded { _ in
                textAdded = true
        }
    }
    
    private var canCreate: Bool {
        if urlVideo != nil || chosenImage != nil {
            return true
        }
        return false
    }
    
    private var overviewTextMaxHeightOffset: CGFloat {
        return mediaSize.height / 2 - 40
    }
}

struct NewWeather: View {
    @Binding var isPresented: Bool
    @Binding var isPresenting: Bool
    @State var isAbleToDone: Bool = true
    @ObservedObject var lm = LocationFetcher()
    @ObservedObject var newWeatherModel = NewWeatherMemoryViewModel()
    @Binding var isShowingDoneAlert: Bool
    @State var presentingAlert = false
    @State var didFetch = false
    @State var alreadyPresentedCantFigureOutLocation = false
    
    var body: some View {
        VStack {
            NewTopBar(isPresenting: $isPresenting, isPresented: $isPresented, isAbleToDone: $isAbleToDone, model: newWeatherModel, isShowingDoneAlert: $isShowingDoneAlert, title: "New Weather Memory")
            content
                .restrictedWidth()
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 5) {
                VStack(spacing: 0) {
                    Picker("Weather", selection: $newWeatherModel.type) {
                        ForEach(newWeatherModel.weatherTypes) { type in
                            Image(type.rawValue)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(3)
                                .tag(type)
                        }
                    }
                    TextField("Description", text: $newWeatherModel.description)
                        .font(Font.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                        .padding()
                }
                TextField("Tempeature", text: $newWeatherModel.temp)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 30, weight: .black))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                    .padding()
                VStack {
                    HStack {
                        Text("Humidity")
                            .font(Font.system(size: 16, weight: .medium))
                        Spacer()
                        TextField("Humidity", text: $newWeatherModel.humidity)
                            .multilineTextAlignment(.trailing)
                            .font(Font.system(size: 16, weight: .bold))
                    }
                    HStack {
                        Text("Wind speed")
                            .font(Font.system(size: 16, weight: .medium))
                        Spacer()
                        TextField("Wind speed", text: $newWeatherModel.wind)
                            .multilineTextAlignment(.trailing)
                            .font(Font.system(size: 16, weight: .bold))
                    }
                    HStack {
                        Text("Pressure")
                            .font(Font.system(size: 16, weight: .medium))
                        Spacer()
                        TextField("Pressure", text: $newWeatherModel.pressure)
                            .multilineTextAlignment(.trailing)
                            .font(Font.system(size: 16, weight: .bold))
                    }
                }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                    .padding()
                Spacer()
                TextField("Location", text: $newWeatherModel.locationName)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 16, weight: .light))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Constants.quaternaryColor))
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: lm.lastKnownLocation, perform: { location in
            if lm.isAuthorized && !didFetch {
                newWeatherModel.fetchWeather(lat: location.latitude, lon: location.longitude)
                didFetch = true
            }
        })
        .onChange(of: lm.locationStatus, perform: { status in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                presentingAlert = false
            default:
                if !alreadyPresentedCantFigureOutLocation {
                    presentingAlert = true
                }
                alreadyPresentedCantFigureOutLocation = true
            }
        })
        .alert(isPresented: $presentingAlert) { () -> Alert in
            Alert(title: Text("Can't access location."), message: Text("To download current weather data, please allow location access in settings."), dismissButton: .default(Text("Ok")))
        }
    }
}

struct NewTopBar<Model>: View where Model: ObservableObject, Model: NewMemoryViewModel {
    @Binding var isPresenting: Bool
    @Binding var isPresented: Bool
    @Binding var isAbleToDone: Bool
    @ObservedObject var model: Model
    @Binding var isShowingDoneAlert: Bool
    
    @State var title: String = ""
    
    @Binding var urlToRemove: URL?
    
    init(isPresenting: Binding<Bool>, isPresented: Binding<Bool>, isAbleToDone: Binding<Bool>, model: Model, isShowingDoneAlert: Binding<Bool>, title: String, urlToRemove: Binding<URL?>? = Binding.constant(nil)) {
        self._isPresenting = isPresenting
        self._isPresented = isPresented
        self._isAbleToDone = isAbleToDone
        self.model = model
        self._isShowingDoneAlert = isShowingDoneAlert
        
        self._title = State(initialValue: title)
        
        self._urlToRemove = urlToRemove ?? Binding.constant(nil)
    }
    
    var body: some View {
        HStack {
            CloseButton(close: $isPresented, withAAnimation: true, urlToRemove: $urlToRemove)
            Spacer()
            Text("\(title)")
                .font(Font.system(size: 17, weight: .bold))
            Spacer()
            Button {
                if isAbleToDone {
                    DispatchQueue.global(qos: .userInteractive).async {
                        model.create()
                    }
                    withAnimation {
                        isPresented = false
                        isShowingDoneAlert = true
                    }
                }
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(Font.system(size: 25, weight: .bold))
                    .foregroundColor(doneButtonFoegroundColor)
            }
            .hoverEffect()
        }
            .padding()
            .padding(.top, 5)
    }
    
    private var doneButtonFoegroundColor: Color {
        if isAbleToDone {
            return Constants.tetriaryColor
        } else {
            return Constants.quaternaryColor
        }
    }
}
