//
//  MemoryView.swift
//  Memorio
//
//  Created by Michal Dobes on 13/08/2020.
//

import SwiftUI
import MapKit
import Photos

struct MemoryView: View {
    @ObservedObject var memoryViewModel: MemoryViewModel
    @Environment(\.presentationMode) var presentation
    @State var showSharePopOver = false
    @State var isShowingDoneHud = false
    @State var loadingShare = false
    @State var showPlus = false
    
    var body: some View {
        ZStack {
            MemoryDetailView()
                .transition(.identity)
            MemoryOverlayView(showSharePopOver: $showSharePopOver)
            if showSharePopOver {
                Rectangle()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)
                    .onTapGesture {
                        withAnimation {
                            if !loadingShare {
                                showSharePopOver = false
                            }
                        }
                    }
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            if !loadingShare {
                                showSharePopOver = false
                            }
                        }
                    }
                MemoryShareView(isPresented: $showSharePopOver, showPlus: $showPlus, loadingShare: $loadingShare)
                    .transition(.move(edge: .bottom))
            }
            if showPlus {
                Rectangle()
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0)
                    .onTapGesture {
                        withAnimation {
                            showPlus = false
                        }
                    }
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            showPlus = false
                        }
                    }
                PlusView(isPresented: $showPlus, plusViewModel: PlusViewModel())
            }
        }
        .environmentObject(memoryViewModel)
    }
}

struct MemoryDetailView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MemoryBackgroundView()
                    .ignoresSafeArea(.container, edges: .bottom)
                    .transition(.identity)
                MemoryContentView()
                    .padding(40)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    .transition(.identity)
            }
        }
    }
}

struct MemoryBackgroundView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Group {
            switch memoryViewModel.currentMemoryType {
            case .text:
                Rectangle()
                    .fill(textGradient)
            case .weather:
                Rectangle()
                    .fill(weatherGradient)
            case .activity:
                Rectangle()
                    .fill(activityGradient)
            case .feeling:
                Rectangle()
                    .fill(feelingGradient)
            case .location:
                DetailMapView(centerCoordinate: $memoryViewModel.location, annotations: $memoryViewModel.locationAnnotation, thumbnail: $memoryViewModel.thumbImage)
                    .id(memoryViewModel.currentMemory.id)
            case .media:
                GeometryReader { geometry in
                    if memoryViewModel.mediaType == .photo {
                        Image(uiImage: memoryViewModel.mediaImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    } else if memoryViewModel.mediaType == .video, let url = memoryViewModel.mediaVideoUrl {
                        MediaPlayer(player: AVPlayer(url: url), timePosition: .middleBottom)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                }
                .id(memoryViewModel.currentMemory.id)
            }
        }
    }
    
    private let weatherGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.483376801, green: 0.7368327975, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.04028664902, green: 0.2656924129, blue: 0.7338536978, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let feelingGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9909259677, green: 0.8056030869, blue: 0.3940483928, alpha: 1)), Color(#colorLiteral(red: 0.8550700545, green: 0.6091246009, blue: 0, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let textGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9146289229, green: 0.9147388339, blue: 0.9145917296, alpha: 1)), Color(#colorLiteral(red: 0.6766527891, green: 0.6732463241, blue: 0.6731149554, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let activityGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4075785577, green: 0.9416559935, blue: 0.3719922304, alpha: 1)), Color(#colorLiteral(red: 0.2030615509, green: 0.5695778728, blue: 0.04902239889, alpha: 1))]), startPoint: .top, endPoint: .bottom)
}

struct MemoryContentView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Group {
            switch memoryViewModel.currentMemoryType {
            case .text:
                VStack(spacing: 24) {
                    HStack {
                        Text(memoryViewModel.title)
                            .font(Font.system(size: 29, weight: .black))
                            .foregroundColor(.black)
                        Spacer()
                    }
                        .padding(14)
                        .padding(.horizontal, 2)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                        ScrollView {
                            HStack {
                                Text(memoryViewModel.content)
                                    .font(Font.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                            .frame(maxHeight: .infinity)
                            .padding(18)
                            .padding(.horizontal, 2)
                            .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                }
                .frame(maxHeight: .infinity)
                .restrictedWidth()
            case .weather:
                VStack(spacing: 0) {
                    Spacer()
                    Image(memoryViewModel.weatherImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100)
                    Text(memoryViewModel.title)
                        .font(Font.system(size: 64, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text(memoryViewModel.content)
                        .font(Font.system(size: 17, weight: .light))
                        .foregroundColor(.white)
                    VStack {
                        HStack {
                            Text("Humidity")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherHumidity)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Wind speed")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherWind)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Pressure")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherPressure)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                        .padding(.top, 40)
                    Spacer()
                    Text(memoryViewModel.weatherLocation)
                        .foregroundColor(.white)
                        .font(Font.system(size: 14, weight: .light))
                }
                .restrictedWidth()
            case .activity:
                VStack(spacing: 65) {
                    Image(systemName: "gamecontroller")
                        .font(Font.system(size: 74, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 65)
                    HStack {
                        Text(memoryViewModel.title)
                            .font(Font.system(size: 29, weight: .black))
                            .foregroundColor(.black)
                        Spacer()
                    }
                        .padding(14)
                        .padding(.horizontal, 2)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                    Spacer()
                }
                .restrictedWidth()
            case .feeling:
                VStack(spacing: 2) {
                    ZStack {
                        HStack {
                            Spacer()
                            Text(memoryViewModel.title)
                                .font(Font.system(size: 29, weight: .black))
                                .foregroundColor(.black)
                            Spacer()
                        }
                            .padding(14)
                            .padding(.horizontal, 2)
                            .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                        Text(memoryViewModel.feelingEmoji)
                            .font(Font.system(size: 124))
                            .offset(x: 0, y: -80)
                    }
                    VStack {
                        HStack {
                            ScrollView {
                                Text(memoryViewModel.content)
                                    .font(Font.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                        .padding(18)
                        .padding(.horizontal, 2)
                        .aspectRatio(1, contentMode: .fit)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                }
                .restrictedWidth()
            default: EmptyView()
            }
        }
    }
}

struct MemoryOverlayView: View {
    @Binding var showSharePopOver: Bool
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(memoryViewModel.currentMemoryDate)
                    .padding(6)
                    .padding(.horizontal, 3)
                    .blurredBackground()
                    .font(Font.system(size: 17, weight: .heavy))
                    .foregroundColor(.white)
                    .transition(.identity)
                Spacer()
                VStack(spacing: 0) {
                    Text("\(memoryViewModel.currentMemoryPosition) out of \(memoryViewModel.memoryCount)")
                        .padding(.top, 6)
                        .padding(.horizontal, 9)
                        .font(Font.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .transition(.identity)
                    ProgressBar()
                }
                .fixedSize()
                .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))).transition(.identity)
                .cornerRadius(13)
                    
            }
            HStack {
                Text(memoryViewModel.currentMemoryTime)
                    .padding(6)
                    .padding(.horizontal, 3)
                    .blurredBackground()
                    .font(Font.system(size: 17, weight: .heavy))
                    .foregroundColor(.white)
                    .transition(.identity)
                Spacer()
            }
            .padding(.top, 4)
            HStack {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture{
                        withAnimation {
                            memoryViewModel.prevMemory()
                        }
                    }
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture{
                        withAnimation {
                            memoryViewModel.nextMemory()
                        }
                    }
            }
            .ignoresSafeArea(.all, edges: .horizontal)
            HStack {
                Button {
                    memoryViewModel.isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(12)
                        .blurredBackground()
                        .font(Font.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                }
                .hoverEffect()
                Spacer()
                Button {
                    withAnimation {
                        showSharePopOver = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .frame(width: 30, height: 30, alignment: .center)
                        .padding(12)
                        .blurredBackground()
                        .font(Font.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                }
                .hoverEffect()
            }
        }
        .padding(8)
    }
}

struct MemoryScreenshotView: View {
    @Binding var date: Bool
    @Binding var time: Bool
    @Binding var watermark: Bool
    @ObservedObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        ZStack {
            MemoryScreenshotDetailView().environmentObject(memoryViewModel)
            MemoryScreenshotOverlayView(date: $date, time: $time, watermark: $watermark).environmentObject(memoryViewModel)
        }
    }
}

struct MemoryScreenshotDetailView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MemoryScreenshotBackgroundRectangleView()
                    .ignoresSafeArea()
                    .transition(.identity)
                MemoryScreenshotContentView()
                    .padding(40)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    .transition(.identity)
            }
        }
    }
}

struct MemoryScreenshotBackgroundRectangleView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Group {
            switch memoryViewModel.currentMemoryType {
            case .text:
                Rectangle()
                    .fill(textGradient)
            case .weather:
                Rectangle()
                    .fill(weatherGradient)
            case .activity:
                Rectangle()
                    .fill(activityGradient)
            case .feeling:
                Rectangle()
                    .fill(feelingGradient)
            case .location:
                Image(uiImage: memoryViewModel.thumbImage)
            case .media:
                Image(uiImage: memoryViewModel.mediaImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
            }
        }
    }
    
    private let weatherGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.483376801, green: 0.7368327975, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.04028664902, green: 0.2656924129, blue: 0.7338536978, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let feelingGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9909259677, green: 0.8056030869, blue: 0.3940483928, alpha: 1)), Color(#colorLiteral(red: 0.8550700545, green: 0.6091246009, blue: 0, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let textGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9146289229, green: 0.9147388339, blue: 0.9145917296, alpha: 1)), Color(#colorLiteral(red: 0.6766527891, green: 0.6732463241, blue: 0.6731149554, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    private let activityGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4075785577, green: 0.9416559935, blue: 0.3719922304, alpha: 1)), Color(#colorLiteral(red: 0.2030615509, green: 0.5695778728, blue: 0.04902239889, alpha: 1))]), startPoint: .top, endPoint: .bottom)
}

struct MemoryScreenshotOverlayView: View {
    @Binding var date: Bool
    @Binding var time: Bool
    @Binding var watermark: Bool
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if date {
                HStack {
                    Text(memoryViewModel.currentMemoryDate)
                        .padding(6)
                        .padding(.horizontal, 3)
                        .background(RoundedRectangle(cornerRadius: 13)
                                        .opacity(0.55)
                                        .shadow(radius: 30)
                                        .foregroundColor(Color(#colorLiteral(red: 0.3557319045, green: 0.3557319045, blue: 0.3557319045, alpha: 1))))
                        .font(Font.system(size: 17, weight: .heavy))
                        .foregroundColor(.white)
                        .transition(.identity)
                    Spacer()
                        
                }
            }
            if time {
                HStack {
                    Text(memoryViewModel.currentMemoryTime)
                        .padding(6)
                        .padding(.horizontal, 3)
                        .background(RoundedRectangle(cornerRadius: 13)
                                        .opacity(0.55)
                                        .shadow(radius: 30)
                                        .foregroundColor(Color(#colorLiteral(red: 0.3557319045, green: 0.3557319045, blue: 0.3557319045, alpha: 1))))
                        .font(Font.system(size: 17, weight: .heavy))
                        .foregroundColor(.white)
                        .transition(.identity)
                    Spacer()
                }
                    .padding(.top, 4)
                }
            Spacer()
            if watermark {
                HStack {
                    Spacer()
                    HStack {
                        Text("via Memorio")
                        Image("icon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                        .padding(6)
                        .padding(.horizontal, 3)
                        .background(RoundedRectangle(cornerRadius: 13)
                                        .opacity(0.55)
                                        .shadow(radius: 30)
                                        .foregroundColor(Color(#colorLiteral(red: 0.3557319045, green: 0.3557319045, blue: 0.3557319045, alpha: 1))))
                        .font(Font.system(size: 14, weight: .light))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(8)
    }
}

struct MemoryScreenshotContentView: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Group {
            switch memoryViewModel.currentMemoryType {
            case .text:
                VStack(spacing: 24) {
                    HStack {
                        Text(memoryViewModel.title)
                            .font(Font.system(size: 29, weight: .black))
                            .foregroundColor(.black)
                        Spacer()
                    }
                        .padding(14)
                        .padding(.horizontal, 2)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                    HStack {
                        Text(memoryViewModel.content)
                            .font(Font.system(size: 17, weight: .semibold))
                            .minimumScaleFactor(0.3)
                            .foregroundColor(.black)
                        Spacer()
                    }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(18)
                        .padding(.horizontal, 2)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .weather:
                VStack(spacing: 0) {
                    Spacer()
                    Image(memoryViewModel.weatherImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 100, maxHeight: 100)
                    Text(memoryViewModel.title)
                        .font(Font.system(size: 64, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 4)
                    Text(memoryViewModel.content)
                        .font(Font.system(size: 17, weight: .light))
                        .foregroundColor(.white)
                    VStack {
                        HStack {
                            Text("Humidity")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherHumidity)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Wind speed")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherWind)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Pressure")
                                .font(Font.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(memoryViewModel.weatherPressure)
                                .font(Font.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                        .padding(.top, 40)
                    Spacer()
                    Text(memoryViewModel.weatherLocation)
                        .foregroundColor(.white)
                        .font(Font.system(size: 14, weight: .light))
                }
            case .activity:
                VStack(spacing: 65) {
                    Image(systemName: "gamecontroller")
                        .font(Font.system(size: 74, weight: .black))
                        .foregroundColor(.white)
                        .padding(.top, 65)
                    HStack {
                        Text(memoryViewModel.title)
                            .font(Font.system(size: 29, weight: .black))
                            .foregroundColor(.black)
                        Spacer()
                    }
                        .padding(14)
                        .padding(.horizontal, 2)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                    Spacer()
                }
            case .feeling:
                VStack(spacing: 2) {
                    ZStack {
                        HStack {
                            Spacer()
                            Text(memoryViewModel.title)
                                .font(Font.system(size: 29, weight: .black))
                                .foregroundColor(.black)
                            Spacer()
                        }
                            .padding(14)
                            .padding(.horizontal, 2)
                            .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                        Text(memoryViewModel.feelingEmoji)
                            .font(Font.system(size: 124))
                            .offset(x: 0, y: -80)
                    }
                    VStack {
                        HStack {
                            ScrollView {
                                Text(memoryViewModel.content)
                                    .font(Font.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                        .padding(18)
                        .padding(.horizontal, 2)
                        .aspectRatio(1, contentMode: .fit)
                        .background(RoundedRectangle(cornerRadius: 13).fill(Color.white))
                }
            default: EmptyView()
            }
        }
    }
}

struct MemoryShareView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    @State private var showingDeletionAlert = false
    @State var presentingShare: Bool = false
    @Binding var showPlus: Bool
    @State var showPlusAlert: Bool = false
    
    @State var date = true
    @State var time = true
    @State var watermark = true
    private var watermarkPasstrought: Binding<Bool> {
        return Binding<Bool> { () -> Bool in
            return watermark
        } set: { (value) in
            if !value, !memoryViewModel.isPlus() {
                watermark = true
                showPlusAlert = true
            } else {
                watermark = value
            }
        }
    }

    
    @State var image = UIImage()
    @State var videoURL: URL?
    
    @State var excludedActivityTypes: [UIActivity.ActivityType]? = [UIActivity.ActivityType.saveToCameraRoll]
    
    @Binding var loadingShare: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    content(for: geometry)
                }
                if presentingShare {
                    ActivityView(activityItems: activityItemToShare, isPresented: $presentingShare, excludedActivityTypes: excludedActivityTypes)
                }
            }
            .onAppear {
                PHPhotoLibrary.requestAuthorization { (status) in
                    switch status {
                    case .authorized, .limited:
                        excludedActivityTypes = nil
                    default:
                        excludedActivityTypes = [UIActivity.ActivityType.saveToCameraRoll]
                    }
                }
            }
        }.restrictedWidth()
    }
    
    private func content(for geometry: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                .fill(Constants.popupBackground)
                .edgesIgnoringSafeArea(.bottom)
            VStack {
                HStack {
                    Text("Share")
                        .font(Font.system(size: 28, weight: .black))
                    Spacer()
                    if loadingShare {
                        Image(systemName: "xmark.circle.fill")
                            .font(Font.system(size: 25, weight: .bold))
                            .foregroundColor(Constants.quaternaryColor)
                    } else {
                        CloseButton(close: $isPresented, withAAnimation: true)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                Spacer()
                Rectangle()
                    .fill(Color(#colorLiteral(red: 0.8661288619, green: 0.86623317, blue: 0.8660934567, alpha: 1)))
                    .aspectRatio(9/16, contentMode: .fit)
                    .blur(radius: 1)
                    .cornerRadius(15)
                    .overlay(
                        VStack(spacing: 2) {
                            if date {
                                HStack {
                                    Rectangle()
                                        .fill(Color(labelsBackgroundColor))
                                        .cornerRadius(9)
                                        .frame(width: 50, height: 17)
                                    Spacer()
                                }
                            }
                            if time {
                                HStack {
                                    Rectangle()
                                        .fill(Color(labelsBackgroundColor))
                                        .cornerRadius(9)
                                        .frame(width: 35, height: 17)
                                    Spacer()
                                }
                            }
                            Spacer()
                            if watermark {
                                HStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(Color(labelsBackgroundColor))
                                        .cornerRadius(9)
                                        .frame(width: 50, height: 17)
                                }
                            }
                        }.padding(8))
                    .padding(.horizontal, 30)
                Spacer()
                VStack {
                    Toggle(isOn: $date) {
                        Text("Date")
                            .font(Font.system(size: 17, weight: .bold))
                    }
                        .toggleStyle(SwitchToggleStyle(tint: Constants.tetriaryColor))
                    Toggle(isOn: $time) {
                        Text("Time")
                            .font(Font.system(size: 17, weight: .bold))
                    }
                        .toggleStyle(SwitchToggleStyle(tint: Constants.tetriaryColor))
                    Toggle(isOn: watermarkPasstrought) {
                        Text("Watermark")
                            .font(Font.system(size: 17, weight: .bold))
                    }
                        .toggleStyle(SwitchToggleStyle(tint: Constants.tetriaryColor))
                        .alert(isPresented: $showPlusAlert) { () -> Alert in
                            Alert(title: Text("Hide watermark"), message: Text("Hiding watermark is available only in Memorio Plus."), primaryButton: .default(Text("Ok")), secondaryButton: .cancel(Text("Memorio Plus"), action: {
                                withAnimation {
                                    showPlus = true
                                }
                            }))
                        }
                }
                    .padding(.horizontal, 48)
                HStack(spacing: 16) {
                    Button {
                        showingDeletionAlert = true
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Constants.deleteColor)
                                .frame(width: 58, height: 58)
                                .cornerRadius(15)
                            Image(systemName: "trash.fill")
                                .font(Font.system(size: 21, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .hoverEffect()
                    .alert(isPresented: $showingDeletionAlert, content: {
                        Alert(title: Text("Are you sure?"), message: Text("This Memory will be deleted permanently."), primaryButton: .destructive(Text("Delete"), action: {
                            memoryViewModel.deleteCurrentMemory()
                            withAnimation {
                                isPresented = false
                            }
                        }), secondaryButton: .cancel())
                    })
                    Button {
                        loadingShare = true
                        if memoryViewModel.currentMemoryType == .media {
                            if memoryViewModel.mediaType == .photo {
                                image = MemoryScreenshotView(date: $date, time: $time, watermark: $watermark, memoryViewModel: memoryViewModel).takeScreenshot(origin: geometry.frame(in: .global).origin, size: CGSize(width: (geometry.size.height/memoryViewModel.mediaImage.size.height) * memoryViewModel.mediaImage.size.width, height: geometry.size.height))
                                presentingShare = true
                                loadingShare = false
                            } else if memoryViewModel.mediaType == .video, let mediaVideoURL = memoryViewModel.mediaVideoUrl {
                                let asset = AVAsset(url: mediaVideoURL).tracks(withMediaType: .video)[0]
                                var size = asset.naturalSize
                                let prefferedTransform = asset.preferredTransform
                                let videoAngle = atan2(prefferedTransform.b, prefferedTransform.a) * 180 / .pi
                                print(videoAngle)
                                if videoAngle == 90 || videoAngle == -90 {
                                    size = CGSize(width: size.height/2, height: size.width/2)
                                } else {
                                    size = CGSize(width: ((geometry.size.height/size.height) * size.width)/2, height: geometry.size.height/2)
                                }
                                let overlayImage = MemoryScreenshotOverlayView(date: $date, time: $time, watermark: $watermark).environmentObject(memoryViewModel).takeScreenshotWithoutBackground(origin: geometry.frame(in: .global).origin, size: size)
                                let videoCompositor = VideoCompositor()
                                DispatchQueue(label: "mdobes.memorio.imageprocessing").async {
                                    videoCompositor.addViewTo(videoURL: mediaVideoURL, watermark: overlayImage!, removeOriginal: false, saveToDirectory: .cachesDirectory, networkUse: true) { (url, error) in
                                        DispatchQueue.main.async {
                                            if let url = url {
                                                videoURL = url
                                                presentingShare = true
                                                loadingShare = false
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            image = MemoryScreenshotView(date: $date, time: $time, watermark: $watermark, memoryViewModel: memoryViewModel).takeScreenshot(origin: geometry.frame(in: .global).origin, size: geometry.size)
                            presentingShare = true
                            loadingShare = false
                        }
                    } label: {
                        ZStack {
                            Rectangle()
                                .fill(Constants.tetriaryGradient)
                                .frame(height: 58)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(15)
                                .shadow(color: Constants.tetriaryColor, radius: 5, x: 0, y: 2)
                            if loadingShare {
                                ProgressView()
                            } else {
                                Text(shareButtonText)
                                    .font(Font.system(size: 21, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .hoverEffect()
                }
                .padding(45)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: (geometry.size.height/4)*3, alignment: .bottom)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var activityItemToShare: [AnyObject] {
        if memoryViewModel.currentMemoryType == .media, memoryViewModel.mediaType == .video, let urlToShare = videoURL {
            return [urlToShare as AnyObject]
        }
        return [image]
    }
    
    private var shareButtonText: String {
        if memoryViewModel.currentMemoryType == .media {
            if memoryViewModel.mediaType == .photo {
                return "Share photo"
            } else if memoryViewModel.mediaType == .video {
                return "Share video"
            }
        }
        return "Share as image"
    }
    
    private let labelsBackgroundColor: UIColor = #colorLiteral(red: 0.74943012, green: 0.7495211959, blue: 0.7493991256, alpha: 1)
}

struct ProgressBar: View {
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        Line()
            .trim(from: 0, to: progress)
            .stroke(linearGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
            .frame(maxHeight: 6)
    }
    
    private var progress: CGFloat {
        let current = Float(memoryViewModel.currentMemoryPosition)
        let total = Float(memoryViewModel.memoryCount)
        return CGFloat(current/total)
    }
    
    private let linearGradient = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0, blue: 0.6549019608, alpha: 1)), Color(#colorLiteral(red: 1, green: 0, blue: 0.431372549, alpha: 1))]), startPoint: .leading, endPoint: .trailing)
}
