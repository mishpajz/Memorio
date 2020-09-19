//
//  PlusView.swift
//  Memorio
//
//  Created by Michal Dobes on 29/08/2020.
//

import SwiftUI

struct PlusView: View {
    @Binding var isPresented: Bool
    @ObservedObject var plusViewModel = PlusViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                content()
            }
            .restrictedWidth()
            if plusViewModel.loading {
                LoadingHudAlert(isShowing: $plusViewModel.loading)
            }
        }
    }
    
    private func content() -> some View {
        VStack {
            HStack(spacing: 0) {
                Text("Memorio")
                    .font(Font.system(size: 28, weight: .black))
                Text("+")
                    .font(Font.system(size: 28, weight: .black))
                    .foregroundColor(Constants.mainColor)
                Spacer()
                CloseButton(close: $isPresented, withAAnimation: true)
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .padding(.bottom)
            VStack {
                featureText(for: "add unlimited Memories in a week")
                featureText(for: "remove watermark")
                featureText(for: "unlock more icons")
                featureText(for: "all future features and updates")
                featureText(for: "support development of the app")
            }
            .padding(.horizontal, 30)
            Button {
                if plusViewModel.isPurchased(id: MemorioPlusProducts.plusLifetime) {
                    plusViewModel.hapticFeedback()
                } else {
                    plusViewModel.purchase(id: MemorioPlusProducts.plusLifetime)
                }
            } label: {
                if plusViewModel.isPurchased(id: MemorioPlusProducts.plusLifetime) {
                    ZStack {
                        Rectangle()
                            .fill(Constants.quaternaryColor)
                            .frame(height: 58)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                        Text("Thank you! 🎉")
                            .font(Font.system(size: 21, weight: .light))
                            .foregroundColor(Constants.secondaryColor)
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Constants.mainGradient)
                            .frame(height: 58)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(15)
                            .shadow(color: Constants.mainColor, radius: 5, x: 0, y: 2)
                        Text(plusViewModel.price(for: MemorioPlusProducts.plusLifetime))
                            .font(Font.system(size: 21, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            .padding(.top)
            Button {
                plusViewModel.restore()
            } label: {
                Text("Restore purchases")
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        }
        .background(RoundedRectangle(cornerRadius: 25.0, style: .continuous)
                        .fill(Constants.popupBackground)
                        .edgesIgnoringSafeArea(.bottom)
                        .transition(.identity)
                        .edgesIgnoringSafeArea(.bottom))
    }
    
    private func featureText(for text: String) -> some View {
        HStack {
            Text("+")
                .font(Font.system(size: 17, weight: .black))
            Text(text)
                .font(Font.system(size: 17, weight: .medium))
                .foregroundColor(Constants.secondaryColor)
            Spacer()
        }
    }
    
    private func iapButton(for value: String, duration: String, productID: String) -> some View {
        Button {
            plusViewModel.purchase(id: productID)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(colorScheme == .dark ? Constants.quaternaryColor : Constants.popupBackground)
                    .shadow(radius: 5)
                if plusViewModel.isPurchased(id: productID) {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Constants.tetriaryGradient, lineWidth: 4)
                }
                VStack {
                    Spacer()
                    Text(value)
                        .font(Font.system(size: 22, weight: .heavy))
                        .foregroundColor(Constants.tetriaryColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Spacer()
                    Text(duration)
                        .font(Font.system(size: 18, weight: .regular))
                        .foregroundColor(.primary)
                }
                .padding(2)
            }
        }
            .aspectRatio(1, contentMode: .fit)
    }
}

struct LoadingHudAlert: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .prominent))
                .cornerRadius(15)
            ProgressView()
        }
            .frame(width: 150, height: 150, alignment: .center)
    }
}
