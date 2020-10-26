//
//  SecurityView.swift
//  Memorio
//
//  Created by Michal Dobes on 25/08/2020.
//

import SwiftUI

struct SecurityView: View {
    
    @ObservedObject var securityViewModel = SecurityViewModel()
    
    var body: some View {
        VStack {
            TitleView(text: "Security")
            VStack {
                Text("Require passcode every time you open Memorio.")
                    .font(Font.system(size: 17, weight: .regular))
                Toggle("App locked", isOn: $securityViewModel.usingAuth)
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle(tint: Constants.tetriaryColor))
                if securityViewModel.usingAuth {
                    if securityViewModel.faceidAvailable {
                        Divider()
                        Toggle("Use Face ID", isOn: $securityViewModel.faceIDInUse)
                            .padding(.horizontal)
                            .toggleStyle(SwitchToggleStyle(tint: Constants.tetriaryColor))
                            .onAppear {
                                if !securityViewModel.canUseFaceID {
                                    securityViewModel.faceIDInUse = false
                                }
                            }
                            .alert(isPresented: $securityViewModel.cantUseFaceIdAlert, content: {
                                Alert(title: Text("Can't use Face ID"), message: Text("Please, make sure Memorio is allowed to use Face ID in settings."), dismissButton: .cancel())
                            })
                    }
                    Divider()
                    Button {
                        securityViewModel.setPin()
                    } label: {
                        Text("Set passcode")
                            .font(Font.system(size: 17, weight: .bold))
                            .foregroundColor(Constants.tetriaryColor)
                            .padding(.vertical, 5)
                    }
                    .hoverEffect()
                }
            }
            .accentColor(Constants.accentColor)
            .tableBackground()
            .padding(.top, 10)
            .restrictedWidth()
            Spacer()
        }
        .fullScreenCover(isPresented: $securityViewModel.settingPin, content: {
            VStack {
                Button {
                    securityViewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(Font.system(size: 25, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .hoverEffect()
                .padding()
                HStack {
                    Spacer()
                    Text(enterPasscodeText)
                        .font(Font.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                HStack {
                    Spacer()
                    HStack {
                        ForEach(0..<4) { i in
                            dot(for: i)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
                .padding(.top, 30)
                PinGrid(viewModel: securityViewModel)
                    .padding(.top, 30)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 60)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Rectangle()
                            .fill(Color(UIColor.systemBackground))
                            .ignoresSafeArea())
        })
    }
    
    private func dot(for number: Int) -> some View {
        Image(systemName: dotImageName(for: number))
            .font(Font.system(size: 17, weight: .black))
            .foregroundColor(securityViewModel.failedPinControl ? Constants.deleteColor : Color.primary)
    }
    
    private func dotImageName(for number: Int) -> String {
        if number < securityViewModel.currentPin.count || securityViewModel.failedPinControl {
            return "circle.fill"
        }
        return "circle"
    }
    
    private var enterPasscodeText: String {
        switch securityViewModel.currentPinSelection {
        case .original:
            return "Enter new passcode"
        case .control:
            return "Confirm new passcode"
        }
    }
}

struct SecurityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SecurityView()
        }
    }
}
