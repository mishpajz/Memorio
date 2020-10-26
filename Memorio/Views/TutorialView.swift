//
//  TutorialView.swift
//  Memorio
//
//  Created by Michal Dobes on 13/09/2020.
//

import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State var currentView: Int = 0
    
    @State var startPos : CGPoint = .zero
    @State var isSwipping = true
    
    private let tutorialTexts = [
        "Memorio allows you to preserve your precious moments.",
        "You can create multiple types of Memories.",
        "See all your Memories in the calendar.",
        "Remember your Memories using Rewind."
    ]
    
    var body: some View {
        VStack {
            title
                .transition(.opacity)
                .animation(.easeIn(duration: 0.5))
            Spacer()
            tutorialContent()
                .restrictedWidth()
            Spacer()
            tutorialText
            bottomBar
                .padding(.top, 25)
                .restrictedWidth()
        }
        .background(Rectangle().fill(Color(UIColor.systemBackground)))
        .edgesIgnoringSafeArea(.bottom)
        .gesture(DragGesture()
                .onChanged { gesture in
                    self.startPos = gesture.location
                    self.isSwipping.toggle()
                }
                .onEnded { gesture in
                    let xDist =  abs(gesture.location.x - self.startPos.x)
                    let yDist =  abs(gesture.location.y - self.startPos.y)
                    if self.startPos.x > gesture.location.x && yDist < xDist {
                        withAnimation {
                            if currentView + 1 == tutorialTexts.count {
                                UserDefaults.standard.set(true, forKey: Constants.isNotFirstLaunch)
                                isPresented = false
                            } else {
                                currentView += 1
                            }
                        }
                    }
                    else if self.startPos.x < gesture.location.x && yDist < xDist {
                        withAnimation {
                            if currentView != 0 {
                                currentView -= 1
                            }
                        }
                    }
                    self.isSwipping.toggle()
                }
             )
    }
    
    private var title: some View {
        VStack {
            HStack {
                Text("Welcome to")
                    .font(Font.system(size: 23, weight: .semibold))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            HStack {
                Text("Memorio")
                    .font(Font.system(size: 32, weight: .black))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
            .padding()
    }
    
    private var bottomBar: some View {
        ZStack {
            dots
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        if currentView + 1 == tutorialTexts.count {
                            UserDefaults.standard.set(true, forKey: Constants.isNotFirstLaunch)
                            isPresented = false
                        } else {
                            currentView += 1
                        }
                    }
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(Constants.mainColor)
                        .font(Font.system(size: 30, weight: .semibold))
                }
                .hoverEffect()
                .padding()
            }
        }
        .padding()
    }
    
    private var dots: some View {
        HStack {
            ForEach(0..<tutorialTexts.count) { i in
                Circle()
                    .frame(width: 10, height: 10, alignment: .center)
                    .foregroundColor(i <= currentView ? Constants.secondaryColor : Constants.quaternaryColor)
            }
        }
    }
    
    private var tutorialText: some View {
        Text(tutorialTexts[currentView])
            .font(Font.system(size: 20, weight: .regular))
    }
    
    private func tutorialContent() -> some View {
        Group {
            switch currentView {
            case 0:
                Image("Icon")
                    .resizable()
                    .frame(maxWidth: 100, maxHeight: 100)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
            case 1:
                VStack(spacing: 30) {
                    LazyVGrid(columns: [GridItem(.fixed(20)), GridItem(.flexible(minimum: 20, maximum: 100))], spacing: 3, content: {
                        ForEach(0..<memoryTypes.count) { i in
                            Image(systemName: memoryTypes[i].0)
                                .font(Font.system(size: 20, weight: .semibold))
                                .foregroundColor(Constants.tetriaryColor)
                            Text(memoryTypes[i].1)
                                .font(Font.system(size: 20, weight: .semibold))
                                .foregroundColor(Constants.tetriaryColor)
                        }
                    })
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.quaternaryColor)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 60, height: 60, alignment: .center)
                        Image(systemName: "plus")
                            .font(Font.system(size: 41, weight: .heavy))
                            .foregroundColor(Constants.secondaryColor)
                    }
                }
            case 2:
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(maxWidth: 135, maxHeight: 25)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    ForEach(0..<4) { i in
                        HStack {
                            ForEach(0..<8) { q in
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor( selectedDaysCoordinates.contains( where: { (i, q) == $0 }) ? Constants.tetriaryColor : Constants.quaternaryColor)
                                    .aspectRatio(4/5, contentMode: .fit)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal, 20)
            case 3:
                ZStack {
                    VStack {
                        HStack {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(maxWidth: 135, maxHeight: 25)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        ForEach(0..<4) { i in
                            HStack {
                                ForEach(0..<8) { q in
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(Constants.quaternaryColor)
                                        .aspectRatio(4/5, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .aspectRatio(323/108, contentMode: .fit)
                            .foregroundColor(Constants.tetriaryColor)
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            default:
                EmptyView()
            }
        }
    }
    
    private let memoryTypes = [
        ("camera", "Media"),
        ("doc.text", "Text"),
        ("smiley", "Feeling"),
        ("cloud.sun", "Weather"),
        ("mappin.and.ellipse", "Location"),
        ("gamecontroller", "Activity")
    ]
    
    private let selectedDaysCoordinates = [
        (0, 1),
        (1, 4),
        (2, 3),
        (3, 5)
    ]
}
