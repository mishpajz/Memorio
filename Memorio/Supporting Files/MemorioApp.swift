//
//  MemorioApp.swift
//  Memorio
//
//  Created by Michal Dobes on 08/08/2020.
//

import SwiftUI

@main
struct MemorioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var tabBarIndex = 0
    @State var showPopOver = false
    @State var showHudAlert = false
    @State var showPlus = false
    @State var showTutorial = false
    @State var checkedLogin = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    @Namespace private var newAnimation
    
    @ObservedObject var loginViewModel = LoginViewModel()
    @ObservedObject var plusViewModel = PlusViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                VStack(spacing: 0) {
                    MemorioContentView(tabBarIndex: $tabBarIndex, presentingPlus: $showPlus)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    TabBarView(tabBarIndex: $tabBarIndex, showPopOver: $showPopOver, showPlus: $showPlus)
                }
                .edgesIgnoringSafeArea(.bottom)
                .onAppear(perform: {
                    if !UserDefaults.standard.bool(forKey: Constants.isNotFirstLaunch) {
                        showTutorial = true
                    }
                })
                if showPopOver {
                    Rectangle()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0)
                        .onTapGesture {
                            withAnimation {
                                showPopOver = false
                            }
                        }
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                showPopOver = false
                            }
                        }
                    NewView(isPresented: $showPopOver, isShowingDoneAlert: $showHudAlert)
                        .transition(.asymmetric(insertion: AnyTransition.scale(scale: 1, anchor: .bottom).combined(with: .opacity), removal: .identity))
                        .matchedGeometryEffect(id: "NewView", in: newAnimation, properties: .size, anchor: .bottom, isSource: true)
                }
                if showPlus {
                    Rectangle()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(0)
                        .onTapGesture {
                            withAnimation {
                                if !plusViewModel.loading {
                                    showPlus = false
                                }
                            }
                        }
                    VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation {
                                if !plusViewModel.loading {
                                    showPlus = false
                                }
                            }
                        }
                    PlusView(isPresented: $showPlus, plusViewModel: plusViewModel)
                }
                if showHudAlert {
                    DoneHudAlert(isShowing: $showHudAlert)
                        .transition(.asymmetric(insertion: .identity, removal: .opacity))
                }
                if !loginViewModel.authenticated {
                    LoginView()
                        .environmentObject(loginViewModel)
                        .ignoresSafeArea(.all, edges: .all)
                        .onAppear {
                            DispatchQueue.global().async {
                                loginViewModel.checkIfShouldRequireAuth()
                                if loginViewModel.usingAuthentication() {
                                    if !loginViewModel.authenticationCancelledByUser {
                                        loginViewModel.authUsingBiometrics()
                                    }
                                }
                            }
                        }
                }
                if showTutorial {
                    TutorialView(isPresented: $showTutorial)
                        .transition(.asymmetric(insertion: .identity, removal: .slide))
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .transactionFinished), perform: { _ in
                plusViewModel.validateSubscriptions()
            })
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                PersistentStore.shared.save()
            case .inactive:
                if loginViewModel.usingAuthentication() {
                    loginViewModel.unAuthenticate()
                    loginViewModel.resetAuthentication()
                }
            case .active:
                NotificationCenter.default.post(name: .newDataInCoreData, object: nil)
            break
            default: break
            }
        }
    }
}

struct MemorioContentView: View {
    @Binding var tabBarIndex: Int
    @Binding var presentingPlus: Bool
    
    var body: some View {
        Group {
            switch tabBarIndex {
            case 0:
                CalendarView(calendarViewModel: CalendarViewModel())
            case 1:
                SettingsView(presentingPlus: $presentingPlus)
            default:
                EmptyView()
                
            }
        }
    }
}

struct TabBarView: View {
    @Binding var tabBarIndex: Int
    @Binding var showPopOver: Bool
    
    @Namespace private var newAnimation
    
    @ObservedObject var model = TabBarViewModel()
    
    @State var needsPlusAlert = false
    @Binding var showPlus: Bool
    
    var body: some View {
        VStack {
            Divider()
            HStack {
                Spacer()
                Button {
                    tabBarIndex = 0
                } label: {
                    Image(systemName: "calendar")
                        .font(Font.system(size: 28, weight: .heavy))
                        .foregroundColor(self.tabBarIndex == 0 ? Constants.tetriaryColor : Constants.secondaryColor)
                }
                    .buttonStyle(PlainButtonStyle())
                    .hoverEffect()
                Spacer()
                Button {
                    if model.isAvailable() {
                        withAnimation {
                            hapticFeedback()
                            showPopOver = true
                        }
                    } else {
                        needsPlusAlert = true
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Constants.quaternaryColor)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 60, height: 60, alignment: .center)
                            .scaleEffect(showPopOver ? 5 : 1, anchor: .bottom)
                            .matchedGeometryEffect(id: "NewView", in: newAnimation)
                        Image(systemName: "plus")
                            .font(Font.system(size: 41, weight: .heavy))
                            .foregroundColor(Constants.secondaryColor)
                    }
                }
                .ignoresSafeArea()
                .buttonStyle(PlainButtonStyle())
                .hoverEffect()
                .alert(isPresented: $needsPlusAlert) { () -> Alert in
                    Alert(title: Text("Add Memory"), message: Text("Adding more than 2 Memories a week is available only in Memorio Plus."), primaryButton: .default(Text("Ok")), secondaryButton: .cancel(Text("Memorio Plus"), action: {
                        withAnimation {
                            showPlus = true
                        }
                    }))
                }
                Spacer()
                Button {
                    tabBarIndex = 1
                } label: {
                    Image(systemName: "gear")
                        .font(Font.system(size: 28, weight: .heavy))
                        .foregroundColor(self.tabBarIndex == 1 ? Constants.tetriaryColor : Constants.secondaryColor)
                }
                    .buttonStyle(PlainButtonStyle())
                .hoverEffect()
                Spacer()
            }
            .padding(.vertical, 7)
        }
        .padding(.bottom, 10)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred()
    }
}

struct DoneHudAlert: View {
    @Binding var isShowing: Bool
    
    @State private var animationPercentage: CGFloat = .zero
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .prominent))
                .cornerRadius(15)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Checkmark()
                        .trim(from: 0, to: animationPercentage)
                        .stroke(Constants.secondaryColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .animation(.easeIn(duration: 0.4))
                        .onAppear {
                            self.animationPercentage = 1
                        }
                        .padding(15)
                        .offset(x: 35, y: 20)
                    Spacer()
                }
                Spacer()
                Text("Done")
                    .padding()
                    .font(Font.system(size: 26, weight: .bold))
                    .foregroundColor(Constants.secondaryColor)
            }
        }
            .frame(width: 150, height: 150, alignment: .center)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.isShowing.toggle()
                }
            }
    }
}


